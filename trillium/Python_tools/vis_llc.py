#!/usr/bin/env python3
# llc_view.py
# -----------------------------------------------------------------------------
# Usage examples
# --------------
# Tracer (one file):
#   ./llc_view.py temp.data --nx 432 --level 1 --cmap Blues --vmin -2 --vmax 30
#
# Vector (two files U and V):
#   ./llc_view.py U.data V.data --nx 432 --level 1 --mode both --bg-cmap viridis --vmin 0 --vmax 2
#   ./llc_view.py U.data V.data --nx 1080 --level 5 --mode arrows --quiver-step 10 --quiver-color white
#
# Save without showing a window:
#   ./llc_view.py temp.data --nx 432 --no-show -o out.png
#
# Title behavior
# --------------
# If you pass all four of: --startyr --startmo --startdy --deltaT, and the FIRST
# input filename matches "*<10 digits>.data" (where those 10 digits are "ts"),
# the script sets the plot title to llc.ts2dte(ts, deltat=deltaT, startyr=..., startmo=..., startdy=...).
# The title is drawn in a WHITE banner OUTSIDE the plot frame (top-center) and autosized based on pixel height.
#
# Notes
# -----
# * Color limits (--vmin/--vmax) apply to the plotted image (tracer or vector speed).
# * No normalization is applied to your data; imshow uses your raw values.
# * Hover shows raw value at the cursor (tracer value or speed SQRT(U^2 + V^2) (speed) if vectors).
# -----------------------------------------------------------------------------

import os
import re
import argparse
import numpy as np

import matplotlib as mpl
import matplotlib.pyplot as plt

import llc

# -----------------------------
# Matplotlib layout defaults
# -----------------------------
mpl.rcParams.update({
    "figure.subplot.left":   0.0,
    "figure.subplot.bottom": 0.0,
    "figure.subplot.top":    1.0,
    "figure.subplot.right":  1.0,
    "figure.subplot.wspace": 0.0,
    "figure.subplot.hspace": 0.0,
})


# -----------------------------
# Work-area sizing (avoid macOS Dock)
# -----------------------------
def _query_x11_workarea():
    """Return (x,y,w,h) EWMH work area if available (often not on XQuartz)."""
    try:
        from Xlib import display, X  # type: ignore
        d = display.Display()
        root = d.screen().root
        NET_WORKAREA = d.intern_atom('_NET_WORKAREA')
        prop = root.get_full_property(NET_WORKAREA, X.AnyPropertyType)
        if prop and len(prop.value) >= 4:
            x, y, w, h = prop.value[:4]
            return int(x), int(y), int(w), int(h)
    except Exception:
        pass
    return None


def _refresh_after_resize(fig):
    """Best-effort nudge so the canvas actually fills the resized window immediately."""
    try:
        # Draw now and once shortly after the window manager applies geometry
        fig.canvas.draw_idle()
        fig.canvas.flush_events()
        try:
            t = fig.canvas.new_timer(interval=160)
            try:
                t.single_shot = True  # not on all backends
            except Exception:
                pass
            t.add_callback(lambda: (fig.canvas.draw_idle(), fig.canvas.flush_events()))
            t.start()
        except Exception:
            pass
        try:
            # A tiny pause helps some backends (TkAgg) finalize geometry
            plt.pause(0.05)
        except Exception:
            pass
    except Exception:
        pass


def _fit_to_workarea(fig, dock_pad_px=None):
    """
    Resize window to the screen's usable area (not true fullscreen), then force the
    Matplotlib canvas to match that size immediately (no manual nudge needed).
    """
    mgr = fig.canvas.manager
    backend = mpl.get_backend().lower()

    # Fallback pad if we can't detect a work area
    pad = dock_pad_px
    if pad is None:
        try:
            pad = int(os.environ.get("DOCK_PAD_PX", "100"))
        except Exception:
            pad = 100

    try:
        if 'qt' in backend:
            win = mgr.window
            try:
                geo = win.screen().availableGeometry()
                x, y, w, h = geo.x(), geo.y(), geo.width(), geo.height()
            except Exception:
                x, y, w, h = 0, 0, 1600, 900
            try:
                win.showMaximized()
            except Exception:
                pass
            try:
                win.setGeometry(x, y, w, h)
            except Exception:
                pass
            try:
                mgr.resize(w, h)
            except Exception:
                pass
            dpi = fig.get_dpi()
            fig.set_size_inches(w / dpi, h / dpi, forward=True)
            try:
                from PyQt5 import QtWidgets  # type: ignore
                QtWidgets.QApplication.processEvents()
            except Exception:
                pass
            _refresh_after_resize(fig)
            # fall through return
            return

        if 'tkagg' in backend:
            root = mgr.window
            wa = _query_x11_workarea()
            if wa is not None:
                x, y, w, h = wa
            else:
                try:
                    sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
                except Exception:
                    sw, sh = 1600, 900
                w, h = sw, max(200, sh - pad)
            try:
                root.state('zoomed')
            except Exception:
                try:
                    root.attributes('-zoomed', True)
                except Exception:
                    pass
            try:
                root.geometry(f"{w}x{h}+0+0")
            except Exception:
                pass
            try:
                root.update_idletasks()
            except Exception:
                pass
            try:
                sw = root.winfo_width()
                sh = root.winfo_height()
                dpi = fig.get_dpi()
                fig.set_size_inches(max(1, sw) / dpi, max(1, sh) / dpi, forward=True)
                try:
                    mgr.resize(sw, sh)
                except Exception:
                    pass
            except Exception:
                pass
            _refresh_after_resize(fig)
            return

        if 'wx' in backend:
            try:
                import wx  # type: ignore
                frame = mgr.frame
                w, h = wx.GetDisplaySize()
                h = max(200, h - pad)
                frame.SetPosition((0, 0))
                frame.SetSize((w, h))
                try:
                    frame.Layout()
                except Exception:
                    pass
                try:
                    mgr.resize(w, h)
                except Exception:
                    pass
                dpi = fig.get_dpi()
                fig.set_size_inches(w / dpi, h / dpi, forward=True)
                _refresh_after_resize(fig)
                return
            except Exception:
                pass

        if 'macosx' in backend:
            # The macOS backend manages its own Cocoa window; toggling fullscreen twice tends
            # to force the canvas to adopt the window size immediately without staying fullscreen.
            try:
                mgr.full_screen_toggle()
                mgr.full_screen_toggle()
            except Exception:
                pass
            try:
                # Also set a large figure size directly as a fallback
                dpi = fig.get_dpi()
                w, h = 1680, 950
                fig.set_size_inches(w / dpi, h / dpi, forward=True)
            except Exception:
                pass
            _refresh_after_resize(fig)
            return

        if 'gtk' in backend:
            try:
                mgr.window.maximize()
            except Exception:
                pass
            _refresh_after_resize(fig)
            return

        # Last resort: DPI-based sizing
        sw, sh = 1920, 1080
        try:
            sw = mgr.window.winfo_screenwidth()
            sh = mgr.window.winfo_screenheight()
        except Exception:
            pass
        dpi = fig.get_dpi()
        fig.set_size_inches(sw / dpi, (sh - pad) / dpi, forward=True)
        try:
            mgr.resize(sw, sh)
        except Exception:
            pass
        _refresh_after_resize(fig)
    except Exception:
        pass


def _ensure_fit_sequence(fig, dock_pad_px):
    """Repeatedly try to fit after the window is realized; helps stubborn WMs/backends."""
    try:
        _fit_to_workarea(fig, dock_pad_px=dock_pad_px)
        delays = (30, 120, 400, 900)
        for ms in delays:
            try:
                t = fig.canvas.new_timer(interval=int(ms))
                try:
                    t.single_shot = True
                except Exception:
                    pass
                t.add_callback(lambda: _fit_to_workarea(fig, dock_pad_px=dock_pad_px))
                t.start()
            except Exception:
                pass
        # fire on first draw too
        fired = {"d": False}
        def _on_first_draw(evt):
            if evt.canvas is fig.canvas and not fired["d"]:
                fired["d"] = True
                _fit_to_workarea(fig, dock_pad_px=dock_pad_px)
        fig.canvas.mpl_connect('draw_event', _on_first_draw)
    except Exception:
        pass

# -----------------------------
# Helpers to call llc APIs robustly
# -----------------------------
def _llc_quikread(path, nx, level, prec):
    """Call llc.quikread with a few possible parameter names (level is 1-based)."""
    try:
        return llc.quikread(path, nx=nx, kx=level, prec=prec)
    except TypeError:
        try:
            return llc.quikread(path, nx=nx, k=level, prec=prec)
        except TypeError:
            return llc.quikread(path, nx=nx, prec=prec)


def _level_to_kidx(A: np.ndarray, level_1based: int) -> int:
    """Clamp 1-based level to 0-based index if 3D; else return 0."""
    A = np.asarray(A)
    if A.ndim == 3:
        return max(0, min(A.shape[2] - 1, int(level_1based) - 1))
    return 0


# -----------------------------
# Title helpers (optional)
# -----------------------------
def _extract_ts_from_filename(path: str) -> int | None:
    """
    Look for a 10-digit timestamp immediately before '.data' in the basename.
    Matches e.g. '1234567890.data' or 'something_1234567890.data'.
    """
    b = os.path.basename(path)
    m = re.search(r'(\d{10})\.data$', b)
    if m:
        try:
            return int(m.group(1))
        except Exception:
            pass
    return None


def _compute_title(files, startyr, startmo, startdy, deltaT) -> str | None:
    """
    If all 4 time inputs are provided and the first filename contains a
    10-digit 'ts' before '.data', call llc.ts2dte(...) and return its output as a string.
    Otherwise return None (leave title blank).
    """
    if (startyr is None) or (startmo is None) or (startdy is None) or (deltaT is None):
        return None
    ts = _extract_ts_from_filename(files[0])
    if ts is None:
        return None
    try:
        title = llc.ts2dte(
            ts,
            deltat=deltaT,
            startyr=int(startyr),
            startmo=int(startmo),
            startdy=int(startdy),
        )
        return str(title)
    except Exception:
        return None


def _add_title_banner(ax, text: str, height=0.065, pad=0.010, alpha=0.98):
    """Reserve a top banner outside the main axes and draw an autosized, readable title.

    - Shrinks the main axes vertically so the banner does not cover data.
    - Adds a white, mostly opaque banner strip across the top.
    - Auto-sizes the font based on banner pixel height.
    """
    if not text:
        return None
    fig = ax.figure

    # 1) Shrink main axes to make room for the banner
    try:
        left, bottom, right, top = 0.0, 0.0, 1.0, 1.0
        ax.set_position([left, bottom, right - left, (top - bottom) - (height + pad)])
    except Exception:
        pass

    # 2) Banner axes at the very top
    y0 = 1.0 - height
    banner_ax = fig.add_axes([0.0, y0, 1.0, height], zorder=10)
    banner_ax.set_facecolor("white")
    banner_ax.patch.set_alpha(float(alpha))
    banner_ax.axis('off')

    # 3) Compute font size from banner pixel height
    fig.canvas.draw()
    dpi = fig.get_dpi()
    fig_h_px = fig.get_size_inches()[1] * dpi
    banner_h_px = height * fig_h_px
    title_px = np.clip(banner_h_px * 0.60, 12, 80)
    title_pt = float(title_px * 72.0 / dpi)

    banner_ax.text(0.5, 0.5, str(text), ha='center', va='center', color='black', fontsize=title_pt)
    return banner_ax


# -----------------------------
# Value lookup from AxesImage
# -----------------------------
def _value_from_axesimage(im, xdata, ydata):
    """Map data coords (xdata,ydata) to nearest (col,row) in imshow array and return value."""
    arr = im.get_array()
    data = np.asarray(arr)
    ny, nx = data.shape[:2]
    xmin, xmax, ymin, ymax = im.get_extent()  # (x0, x1, y0, y1)
    tx = (xdata - xmin) / (xmax - xmin) if xmax != xmin else 0.0
    ty = (ydata - ymin) / (ymax - ymin) if ymax != ymin else 0.0
    col = int(round(tx * (nx - 1)))
    row = int(round(ty * (ny - 1)))
    col = max(0, min(nx - 1, col))
    row = max(0, min(ny - 1, row))
    v = data[row, col]
    if np.ma.isMaskedArray(arr) and arr.mask is not np.ma.nomask:
        if np.ma.getmaskarray(arr)[row, col]:
            v = np.nan
    return col, row, v


# -----------------------------
# Colorbar (top-right overlay) with black, autosized ticks
# -----------------------------
def add_colorbar_top_right(im, ax, width=0.22, height=0.045, pad=0.02, decimals=2,
                           bg_alpha=0.98):
    """
    Add a horizontal colorbar inside `ax`, anchored at the top-right corner.
    Ticks and labels are BLACK and autosized based on rendered pixel height.
    width/height/pad are in Axes (0-1) fraction units.

    Additionally, place a same-size WHITE, mostly opaque background panel behind the colorbar
    so the bar and ticks are always readable regardless of the image underneath.
    """
    fig = ax.figure
    # Create an inset axes at top-right (position only)
    x0 = 1.0 - width - pad
    y0 = 1.0 - height - pad

    # Background panel (same size as colorbar), drawn first
    bg_ax = ax.inset_axes([x0, y0, width, height])
    bg_ax.set_facecolor("white")
    bg_ax.patch.set_alpha(float(bg_alpha))  # mostly opaque
    for spine in bg_ax.spines.values():
        spine.set_visible(False)
    bg_ax.set_xticks([])
    bg_ax.set_yticks([])
    bg_ax.set_zorder(2)

    # Real colorbar axes on top, with transparent face so the white panel shows through
    cax = ax.inset_axes([x0, y0, width, height])
    cax.set_facecolor("none")
    cax.set_zorder(3)

    cb = plt.colorbar(im, cax=cax, orientation='horizontal')

    # Three ticks: vmin, mid, vmax
    vmin, vmax = im.get_clim()
    if np.isfinite(vmin) and np.isfinite(vmax) and vmax != vmin:
        ticks = [vmin, (vmin + vmax) / 2.0, vmax]
        cb.set_ticks(ticks)
        fmt = f"%.{decimals}f"
        cb.set_ticklabels([fmt % t for t in ticks])

    # ---- Autosize tick label font and tick length based on cbar pixel height ----
    fig.canvas.draw()  # ensure renderer is ready
    dpi = fig.dpi
    fig_h_px = fig.get_size_inches()[1] * dpi
    ax_bbox = ax.get_position()
    ax_h_px = ax_bbox.height * fig_h_px
    cbar_h_px = height * ax_h_px

    # Heuristics for readability across resolutions
    label_px = np.clip(cbar_h_px * 0.60, 12, 60)      # label height in px (bumped up min)
    label_pt = float(label_px * 72.0 / dpi)           # -> points
    tick_len_px = np.clip(cbar_h_px * 0.45, 6, 22)    # slightly larger ticks
    tick_len_pt = float(tick_len_px * 72.0 / dpi)
    tick_w_pt = float(np.clip(cbar_h_px * 0.06, 1.2, 3.5))  # width in points

    cb.ax.tick_params(colors="black", length=tick_len_pt, width=tick_w_pt, labelsize=label_pt)
    plt.setp(cb.ax.get_xticklabels(), color="black")
    try:
        cb.outline.set_edgecolor("black")
        cb.outline.set_linewidth(1.2)
    except Exception:
        pass

    # Hide axes spines on top bar (we rely on cb outline)
    for spine in cax.spines.values():
        spine.set_visible(False)

    return cb


# -----------------------------
# Top strip: title (left) + small colorbar (right)
# -----------------------------

def apply_top_strip(ax, im, title_text: str | None, *, strip_h=0.06, pad=0.01, cbar_rel_w=0.35, cbar_height_frac=0.5, decimals=2, bg_alpha=0.98):
    """Create a top strip outside the data canvas with a left-justified title and a
    small horizontal colorbar at the top-right. Shrinks the main axes to make space.

    cbar_rel_w: fraction of the figure's width (within the strip) given to the colorbar (wider -> larger value)
    cbar_height_frac: fraction of the strip's height used for the colorbar (narrower -> smaller value)
    """
    fig = ax.figure
    pos = ax.get_position()

    # 1) Shrink main axes height to make room for the strip at the top
    new_h = pos.height - (strip_h + pad)
    if new_h <= 0:
        new_h = max(0.5 * pos.height, 0.1)
    ax.set_position([pos.x0, pos.y0, pos.width, new_h])

    # 2) Define strip region
    y = pos.y0 + new_h + pad
    gap = pad
    title_w = pos.width * (1.0 - cbar_rel_w) - gap
    cbar_w = pos.width * cbar_rel_w

    # Title area (left)
    title_ax = fig.add_axes([pos.x0, y, max(0.0, title_w), strip_h], zorder=10)
    title_ax.set_facecolor("white")
    title_ax.patch.set_alpha(float(bg_alpha))
    title_ax.axis('off')

    # Right-side strip background to keep a continuous white banner
    cbar_bg_x0 = pos.x0 + max(0.0, title_w) + gap
    cbar_bg_ax = fig.add_axes([cbar_bg_x0, y, cbar_w, strip_h], zorder=9)
    cbar_bg_ax.set_facecolor("white")
    cbar_bg_ax.patch.set_alpha(float(bg_alpha))
    cbar_bg_ax.axis('off')

    # Actual colorbar axis: narrower (height fraction) and centered vertically in the strip
    cbar_h = max(0.05, strip_h * float(cbar_height_frac))
    cbar_y = y + (strip_h - cbar_h) / 2.0
    cax = fig.add_axes([cbar_bg_x0, cbar_y, cbar_w, cbar_h], zorder=11)
    cax.set_facecolor("none")

    # Title text (top-left)
    fig.canvas.draw()
    dpi = fig.get_dpi()
    fig_h_px = fig.get_size_inches()[1] * dpi
    strip_h_px = strip_h * fig_h_px
    title_px = np.clip(strip_h_px * 0.58, 12, 64)
    title_pt = float(title_px * 72.0 / dpi)
    if title_text:
        title_ax.text(0.02, 0.5, str(title_text), ha='left', va='center', color='black', fontsize=title_pt)

    # Colorbar (horizontal, compact)
    cb = plt.colorbar(im, cax=cax, orientation='horizontal')

    # Three ticks: vmin, mid, vmax
    vmin, vmax = im.get_clim()
    if np.isfinite(vmin) and np.isfinite(vmax) and vmax != vmin:
        ticks = [vmin, (vmin + vmax) / 2.0, vmax]
        cb.set_ticks(ticks)
        fmt = f"%.{decimals}f"
        cb.set_ticklabels([fmt % t for t in ticks])

    # Autosize tick labels/ticks based on the *strip* height (not the thinner bar)
    label_px = np.clip(strip_h_px * 0.50, 10, 48)
    label_pt = float(label_px * 72.0 / dpi)
    tick_len_px = np.clip(strip_h_px * 0.35, 4, 16)
    tick_len_pt = float(tick_len_px * 72.0 / dpi)
    tick_w_pt = float(np.clip(strip_h_px * 0.05, 1.0, 3.0))

    cb.ax.tick_params(colors="black", length=tick_len_pt, width=tick_w_pt, labelsize=label_pt)
    plt.setp(cb.ax.get_xticklabels(), color="black")
    try:
        cb.outline.set_edgecolor("black")
        cb.outline.set_linewidth(1.0)
    except Exception:
        pass

    for spine in cax.spines.values():
        spine.set_visible(False)

    return cb


# -----------------------------
# Plotters
# -----------------------------

# -----------------------------
def plot_tracer(A, *, level_1based: int, cmap: str, vmin, vmax, dock_pad_px, add_cbar: bool,
                outfile: str | None, no_show: bool, title_text: str | None = None):
    fig, ax = plt.subplots(constrained_layout=False)
    fig.subplots_adjust(left=0, bottom=0, right=1, top=1, wspace=0, hspace=0)

    kidx0 = _level_to_kidx(A, level_1based)
    im, _ = llc.plot(A, ax=ax, k_index=kidx0)
    if cmap:
        im.set_cmap(cmap)
    if (vmin is not None) or (vmax is not None):
        # raw values; no normalization
        im.set_clim(vmin, vmax)
    ax.set_axis_off()

    # Title outside the plot frame (autosized in a banner)
    if title_text:
        None

    if add_cbar:
        apply_top_strip(ax, im, title_text, strip_h=0.06, pad=0.01, cbar_rel_w=0.35, cbar_height_frac=0.5)

    # Ensure the canvas fills the window from the start (robust sequence)
    _ensure_fit_sequence(fig, dock_pad_px)

    if not no_show:
        _ensure_fit_sequence(fig, dock_pad_px)

        tip = ax.text(5, 5, "", va="top", ha="left",
                      bbox=dict(boxstyle="round", fc="white", ec="none", alpha=0.85))

        def on_move(evt):
            if not evt.inaxes or evt.xdata is None or evt.ydata is None:
                tip.set_visible(False); fig.canvas.draw_idle(); return
            c, r, v = _value_from_axesimage(im, evt.xdata, evt.ydata)
            sval = "nan" if (isinstance(v, float) and np.isnan(v)) else f"{float(v):.6g}"
            tip.set_text(f"x={c}, y={r}, val={sval}")
            tip.set_position((evt.xdata + 10, evt.ydata + 10))
            tip.set_visible(True); fig.canvas.draw_idle()

        def on_click(evt):
            if evt.inaxes and evt.xdata is not None and evt.ydata is not None:
                c, r, v = _value_from_axesimage(im, evt.xdata, evt.ydata)
                print(f"{c}\t{r}\t{v}")

        def on_key(evt):
            k = (evt.key or "").lower()
            if k in ("q", "escape"):
                plt.close(fig)
            elif k == "f":
                _fit_to_workarea(fig, dock_pad_px=dock_pad_px)

        fig.canvas.mpl_connect("motion_notify_event", on_move)
        fig.canvas.mpl_connect("button_press_event", on_click)
        fig.canvas.mpl_connect("key_press_event", on_key)

        # One more nudge shortly after the window appears (helps some WMs)
        try:
            t = fig.canvas.new_timer(interval=200)
            try:
                t.single_shot = True
            except Exception:
                pass
            t.add_callback(lambda: _fit_to_workarea(fig, dock_pad_px=dock_pad_px))
            t.start()
        except Exception:
            pass

    # Save file?
    if outfile:
        fig.savefig(outfile, dpi=fig.dpi, bbox_inches="tight", pad_inches=0)
        print(f"Saved figure to {outfile}")

    if not no_show:
        plt.show()


def plot_vector(U, V, *, level_1based: int, mode: str, cmap: str, vmin, vmax,
                quiver_step: int, quiver_scale, quiver_color: str,
                dock_pad_px, add_cbar: bool, outfile: str | None,
                pad_to_square: bool, mask_zeros: bool, no_show: bool,
                title_text: str | None = None):
    """
    mode: 'bg' | 'arrows' | 'both'
    vmin/vmax: color limits for the background speed (if shown)
    """
    fig, ax = plt.subplots(constrained_layout=False)
    fig.subplots_adjust(left=0, bottom=0, right=1, top=1, wspace=0, hspace=0)

    kidx0 = _level_to_kidx(np.asarray(U), level_1based)

    show_bg = (mode in ("bg", "both"))
    draw_ar = (mode in ("arrows", "both"))

    im, q, out = llc.plot_llc_vector_cgrid(
        U, V,
        ax=ax, k_index=kidx0,
        step=quiver_step,
        scale=quiver_scale,
        quiver_color=quiver_color,
        draw_arrows=draw_ar,
        show_background=show_bg,
        cmap=cmap,
        mask_zeros=mask_zeros,
        pad_to_square=pad_to_square,
        bg_vmin=vmin,     # raw value limits
        bg_vmax=vmax,
    )

    ax.set_axis_off()

    # If arrows only, create an invisible image of SQRT(U^2 + V^2) (speed) so hover can still read raw values
    if (im is None):
        Fbg = np.hypot(out["Uc"], out["Vc"])
        M = np.ma.masked_where(np.isnan(Fbg) | (Fbg == 0), Fbg)
        im = ax.imshow(M.T, origin="lower", interpolation="nearest", aspect="equal",
                       resample=False, cmap=cmap, vmin=vmin, vmax=vmax, alpha=0.0)

    # Title outside the plot frame (autosized in a banner)
    if title_text:
        None

    # Colorbar only if background is visible
    if add_cbar and show_bg:
        apply_top_strip(ax, im, title_text, strip_h=0.06, pad=0.01, cbar_rel_w=0.35, cbar_height_frac=0.5)

    # Ensure the canvas fills the window from the start (robust sequence)
    _ensure_fit_sequence(fig, dock_pad_px)

    if not no_show:
        _ensure_fit_sequence(fig, dock_pad_px)

        tip = ax.text(5, 5, "", va="top", ha="left",
                      bbox=dict(boxstyle="round", fc="white", ec="none", alpha=0.85))

        def on_move(evt):
            if not evt.inaxes or evt.xdata is None or evt.ydata is None:
                tip.set_visible(False); fig.canvas.draw_idle(); return
            c, r, v = _value_from_axesimage(im, evt.xdata, evt.ydata)
            sval = "nan" if (isinstance(v, float) and np.isnan(v)) else f"{float(v):.6g}"
            tip.set_text(f"x={c}, y={r}, Speed={sval}")
            tip.set_position((evt.xdata + 10, evt.ydata + 10))
            tip.set_visible(True); fig.canvas.draw_idle()

        def on_click(evt):
            if evt.inaxes and evt.xdata is not None and evt.ydata is not None:
                c, r, v = _value_from_axesimage(im, evt.xdata, evt.ydata)
                print(f"{c}\t{r}\t{v}")

        def on_key(evt):
            k = (evt.key or "").lower()
            if k in ("q", "escape"):
                plt.close(fig)
            elif k == "f":
                _fit_to_workarea(fig, dock_pad_px=dock_pad_px)

        fig.canvas.mpl_connect("motion_notify_event", on_move)
        fig.canvas.mpl_connect("button_press_event", on_click)
        fig.canvas.mpl_connect("key_press_event", on_key)

        # One more nudge shortly after the window appears (helps some WMs)
        try:
            t = fig.canvas.new_timer(interval=200)
            try:
                t.single_shot = True
            except Exception:
                pass
            t.add_callback(lambda: _fit_to_workarea(fig, dock_pad_px=dock_pad_px))
            t.start()
        except Exception:
            pass

    # Save file?
    if outfile:
        fig.savefig(outfile, dpi=fig.dpi, bbox_inches="tight", pad_inches=0)
        print(f"Saved figure to {outfile}")

    if not no_show:
        plt.show()


# -----------------------------
# CLI
# -----------------------------
def main():
    ap = argparse.ArgumentParser(
        description="LLC viewer for scalar tracer (1 file) or C-grid vectors (2 files). "
                    "Shows raw values (no normalization)."
    )
    ap.add_argument("files", nargs="+", help="Path(s) to LLC .data file(s): 1 for tracer, 2 for vector (U V)")
    ap.add_argument("--nx", type=int, required=True, help="Tile dimension (e.g., 432, 1080)")
    ap.add_argument("--level", type=int, default=1, help="Vertical level (1-based)")
    ap.add_argument("--prec", default="real*4", help="Precision for llc.quikread (e.g., real*4, real*8)")
    # color/limits (apply to tracer or vector-speed background)
    ap.add_argument("--cmap", default="viridis", help="Matplotlib colormap for image")
    ap.add_argument("--vmin", type=float, default=None, help="Min of color axis (raw values)")
    ap.add_argument("--vmax", type=float, default=None, help="Max of color axis (raw values)")
    # vector draw options
    ap.add_argument("--mode", choices=["bg", "arrows", "both"], default="both",
                    help="Vector mode: colorful SQRT(U^2 + V^2) (speed) background, arrows only, or both (only used when 2 files given)")
    ap.add_argument("--quiver-step", type=int, default=8, help="Subsample factor for arrows (larger -> fewer arrows)")
    ap.add_argument("--quiver-scale", default=None,
                    help="Quiver scale (float) or 'auto' (default). Controls arrow size in pixels per data unit.")
    ap.add_argument("--quiver-color", default="black", help="Arrow color")
    # misc
    ap.add_argument("--output", "-o", help="Output PNG path (saved after viewing, or immediately with --no-show)")
    ap.add_argument("--no-show", action="store_true", help="Do not open a window; just save the figure")
    ap.add_argument("--dock-pad", type=int, default=None,
                    help="Bottom padding (px) above Dock when sizing window (fallback). Default 100 or env DOCK_PAD_PX.")
    ap.add_argument("--pad-to-square", action="store_true",
                    help="Pad right side so width=4*nx for a square canvas (useful for some layouts)")
    ap.add_argument("--no-mask-zeros", action="store_true",
                    help="By default, zeros are masked as black. Pass this flag to keep zeros visible.")
    # optional time-origin inputs for title
    ap.add_argument("--startyr", type=int, default=None, help="Start year (used with --startmo/--startdy/--deltaT to title plot)")
    ap.add_argument("--startmo", type=int, default=None, help="Start month (used with --startyr/--startdy/--deltaT to title plot)")
    ap.add_argument("--startdy", type=int, default=None, help="Start day (used with --startyr/--startmo/--deltaT to title plot)")
    ap.add_argument("--deltaT", type=float, default=None, help="Time step (same units expected by llc.ts2dte; used for title)")

    args = ap.parse_args()
    mask_zeros = not args.no_mask_zeros
    title_text = _compute_title(args.files, args.startyr, args.startmo, args.startdy, args.deltaT)

    # --- read files
    if len(args.files) == 1:
        f = args.files[0]
        fld, *_ = _llc_quikread(f, nx=args.nx, level=args.level, prec=args.prec)
        A = np.asarray(fld)
        if A.ndim not in (2, 3):
            raise ValueError(f"Unexpected array shape from llc.quikread: {A.shape}")

        # Save-only path?
        if args.no_show:
            outname = args.output or (os.path.splitext(os.path.basename(f))[0] + f"_lvl{args.level}.png")
            plot_tracer(A, level_1based=args.level, cmap=args.cmap,
                        vmin=args.vmin, vmax=args.vmax,
                        dock_pad_px=args.dock_pad, add_cbar=True,
                        outfile=outname, no_show=True, title_text=title_text)
            return

        # Interactive tracer
        plot_tracer(A, level_1based=args.level, cmap=args.cmap,
                    vmin=args.vmin, vmax=args.vmax,
                    dock_pad_px=args.dock_pad, add_cbar=True,
                    outfile=args.output, no_show=False, title_text=title_text)
        return

    elif len(args.files) == 2:
        fu, fv = args.files
        U, *_ = _llc_quikread(fu, nx=args.nx, level=args.level, prec=args.prec)
        V, *_ = _llc_quikread(fv, nx=args.nx, level=args.level, prec=args.prec)
        U = np.asarray(U); V = np.asarray(V)
        if U.shape[:2] != V.shape[:2]:
            raise ValueError(f"U and V leading shapes differ: {U.shape} vs {V.shape}")

        # Save-only path?
        if args.no_show:
            # produce/save without showing
            outname = args.output or (f"{os.path.splitext(os.path.basename(fu))[0]}_{os.path.splitext(os.path.basename(fv))[0]}_lvl{args.level}.png")
            plot_vector(U, V,
                        level_1based=args.level,
                        mode=args.mode,
                        cmap=args.cmap,
                        vmin=args.vmin, vmax=args.vmax,
                        quiver_step=args.quiver_step,
                        quiver_scale=args.quiver_scale,
                        quiver_color=args.quiver_color,
                        dock_pad_px=args.dock_pad,
                        add_cbar=True,
                        outfile=outname,
                        pad_to_square=args.pad_to_square,
                        mask_zeros=mask_zeros,
                        no_show=True,
                        title_text=title_text)
            return

        # Interactive vector
        plot_vector(U, V,
                    level_1based=args.level,
                    mode=args.mode,
                    cmap=args.cmap,
                    vmin=args.vmin, vmax=args.vmax,
                    quiver_step=args.quiver_step,
                    quiver_scale=args.quiver_scale,
                    quiver_color=args.quiver_color,
                    dock_pad_px=args.dock_pad,
                    add_cbar=True,
                    outfile=args.output,
                    pad_to_square=args.pad_to_square,
                    mask_zeros=mask_zeros,
                    no_show=False,
                    title_text=title_text)
        return

    else:
        raise SystemExit("Pass exactly 1 file (tracer) or 2 files (U V for vectors).")


if __name__ == "__main__":
    main()
