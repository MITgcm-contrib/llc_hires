# llc_vis.py
# -----------------------------------------------------------------------------
# Lightweight LLC visualizers (scalar + C-grid vector), ready to import.
# - plot(...)                -> scalar tracer mosaic
# - plot_llc_vector_cgrid(...) -> vector mosaic with correct face rotations + C->T collocation
#
# Notes
# -----
# * The vector visualizer shows SQRT(U^2 + V^2) (speed) as a colorful background by default.
# * Neither function normalizes your data values; imshow uses your raw values.
# * Both functions return the matplotlib artists so callers can tweak colormaps/clims.
# -----------------------------------------------------------------------------

from __future__ import annotations

from typing import Optional, Tuple, Union
import numpy as np
import matplotlib.pyplot as plt

ArrayLike = Union[np.ndarray]


# -----------------------------------------------------------------------------
# Scalar tracer mosaic
# -----------------------------------------------------------------------------
def plot(fld: np.ndarray, ax: Optional[plt.Axes] = None, k_index: int = 0):
    """
    Plot an LLC mosaic (full field) with 1 pixel per data point.
    Zeros and NaNs are shown as white.

    Accepts:
      - 2D array: (nx, 13*nx)
      - 3D array: (nx, 13*nx, k)  -> selects k_index

    Returns
    -------
    im : AxesImage (for color limits / colormap control)
    F  : 2D array of the mosaicked scalar in display (no transpose)
    """
    if ax is None:
        ax = plt.gca()

    A = np.asarray(fld)
    if A.ndim == 3:
        if not (0 <= k_index < A.shape[2]):
            raise ValueError(f"k_index {k_index} out of range for fld.shape={A.shape}")
        A = A[:, :, k_index]
    elif A.ndim != 2:
        raise ValueError("fld must be 2D (nx x 13*nx) or 3D with a k dimension")

    nx, ny = A.shape
    if ny != 13 * nx:
        raise ValueError(
            f"fld has shape {A.shape}; expected full mosaic width 13*nx={13*nx}. "
            "Did you pass a regional slice or per-face dict?"
        )

    # Face slices
    f1 = A[:, 0:3*nx]
    f2 = A[:, 3*nx:6*nx]
    f3 = A[:, 6*nx:7*nx]

    f4 = f1.T.copy()
    for f in range(8, 11):  # faces 8..10
        i1 = (np.arange(nx) + (f - 8) * nx)
        i2 = (np.arange(0, 3*nx, 3) + 7*nx + (f - 8))
        f4[i1, :] = A[:, i2]

    f5 = f1.T.copy()
    for f in range(11, 14):  # faces 11..13
        i1 = (np.arange(nx) + (f - 11) * nx)
        i2 = (np.arange(0, 3*nx, 3) + 10*nx + (f - 11))
        f5[i1, :] = A[:, i2]

    ny3 = 3 * nx
    F = np.full((4 * nx, ny3 + nx // 2), np.nan, dtype=np.float64)
    F[0:nx, 0:ny3] = f1
    F[nx:2*nx, 0:ny3] = f2
    F[0:nx, ny3:ny3 + nx // 2] = np.rot90(f3[0:(nx // 2), :], 1)
    F[2*nx:3*nx, ny3:ny3 + nx // 2] = np.rot90(f3[(nx // 2):nx, :], 3)
    F[2*nx:3*nx, 0:ny3] = np.rot90(f4, 3)
    F[3*nx:4*nx, 0:ny3] = np.rot90(f5, 3)

    # Mask zeros and NaNs; draw masked ("bad") values as solid black.
    M = np.ma.masked_where(np.isnan(F) | (F == 0), F)
    cmap = plt.get_cmap('viridis').copy()
    cmap.set_bad(color='white', alpha=1.0)

    im = ax.imshow(
        M.T,
        interpolation='nearest',  # no smoothing
        origin='lower',
        aspect='equal',           # square cells (1 block per datum)
        cmap=cmap,
        resample=False
    )

    ax.set_xticks([]); ax.set_yticks([])
    return im, F


# -----------------------------------------------------------------------------
# C-grid vector quiver on the SAME mosaic layout (speed background by default)
# -----------------------------------------------------------------------------
def plot_llc_vector_cgrid(
    u: ArrayLike,
    v: ArrayLike,
    *,
    ax: Optional[plt.Axes] = None,
    k_index: int = 0,
    step: int = 8,
    scale: Union[float, str, None] = None,        # None/"auto" picks visible arrows
    quiver_color: str = "black",
    draw_arrows: bool = True,                      # turn arrows on/off
    show_background: bool = True,                  # show colorful SQRT(U^2 + V^2) (speed) background
    cmap: str = "viridis",
    mask_zeros: bool = True,
    pad_to_square: bool = False,                   # if True, pad right side to width=4*nx
    bg_vmin: Optional[float] = None,               # color axis for background (speed)
    bg_vmax: Optional[float] = None,               # color axis for background (speed)
):
    """
    Build the SAME mosaic as plot(), rotate U/V with faces, C->T collocate, and draw quiver.

    Parameters
    ----------
    u, v : (nx, 13*nx) or (nx, 13*nx, k)
        C-grid components.
    show_background : bool
        If True (default) show SQRT(U^2 + V^2) (speed) as background image with colormap `cmap`.
    draw_arrows : bool
        If True (default) draw quiver arrows of the T-point vectors.
    bg_vmin, bg_vmax : float or None
        If provided, set the background "caxis" (imshow vmin/vmax). If None, auto-scale.

    Returns
    -------
    im : the background image (or None if background is hidden)
    q  : the Quiver object (or None if arrows are hidden)
    out: dict with mosaics {"Fu","Fv","Uc","Vc","Fbg"}  (all un-transposed)
    """
    if ax is None:
        ax = plt.gca()

    # ---- helpers tied to geometry ----
    def _as2d(A: np.ndarray, k: int) -> np.ndarray:
        A = np.asarray(A)
        if A.ndim == 3:
            if not (0 <= k < A.shape[2]):
                raise ValueError(f"k_index {k} out of range for shape {A.shape}")
            A = A[:, :, k]
        elif A.ndim != 2:
            raise ValueError("array must be 2D (nx x 13*nx) or 3D with a k dimension")
        return A

    def _check(A: np.ndarray, name: str) -> int:
        nx, ny = A.shape
        if ny != 13 * nx:
            raise ValueError(f"{name} has shape {A.shape}; need width 13*nx={13*nx}")
        return nx

    def _rotvec(uA: np.ndarray, vA: np.ndarray, k: int) -> Tuple[np.ndarray, np.ndarray]:
        k %= 4
        if k == 0: return uA, vA
        if k == 1: return -vA, uA
        if k == 2: return -uA, -vA
        return vA, -uA  # k==3

    def _mosaic_scalar(A: np.ndarray) -> np.ndarray:
        nx = _check(A, "background")
        f1 = A[:, 0:3*nx]; f2 = A[:, 3*nx:6*nx]; f3 = A[:, 6*nx:7*nx]
        f4 = f1.T.copy()
        for f in range(8, 11):
            i1 = (np.arange(nx) + (f - 8) * nx)
            i2 = (np.arange(0, 3*nx, 3) + 7*nx + (f - 8))
            f4[i1, :] = A[:, i2]
        f5 = f1.T.copy()
        for f in range(11, 14):
            i1 = (np.arange(nx) + (f - 11) * nx)
            i2 = (np.arange(0, 3*nx, 3) + 10*nx + (f - 11))
            f5[i1, :] = A[:, i2]
        ny3 = 3 * nx
        F = np.full((4 * nx, ny3 + nx // 2), np.nan, dtype=float)
        F[0:nx, 0:ny3] = f1
        F[nx:2*nx, 0:ny3] = f2
        F[0:nx, ny3:ny3 + nx // 2] = np.rot90(f3[0:(nx // 2), :], 1)
        F[2*nx:3*nx, ny3:ny3 + nx // 2] = np.rot90(f3[(nx // 2):nx, :], 3)
        F[2*nx:3*nx, 0:ny3] = np.rot90(f4, 3)
        F[3*nx:4*nx, 0:ny3] = np.rot90(f5, 3)
        return F

    def _mosaic_vector(U: np.ndarray, V: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        if U.shape != V.shape:
            raise ValueError(f"u and v must have same shape; got {U.shape} vs {V.shape}")
        nx = _check(U, "u/v")
        u1, v1 = U[:, 0:3*nx], V[:, 0:3*nx]
        u2, v2 = U[:, 3*nx:6*nx], V[:, 3*nx:6*nx]
        u3, v3 = U[:, 6*nx:7*nx], V[:, 6*nx:7*nx]

        u4 = u1.T.copy(); v4 = v1.T.copy()
        for f in range(8, 11):
            i1 = (np.arange(nx) + (f - 8) * nx)
            i2 = (np.arange(0, 3*nx, 3) + 7*nx + (f - 8))
            u4[i1, :] = U[:, i2]; v4[i1, :] = V[:, i2]

        u5 = u1.T.copy(); v5 = v1.T.copy()
        for f in range(11, 14):
            i1 = (np.arange(nx) + (f - 11) * nx)
            i2 = (np.arange(0, 3*nx, 3) + 10*nx + (f - 11))
            u5[i1, :] = U[:, i2]; v5[i1, :] = V[:, i2]

        ny3 = 3 * nx
        Fu = np.full((4 * nx, ny3 + nx // 2), np.nan, dtype=float)
        Fv = np.full_like(Fu, np.nan)

        # Faces 1–2 (no rotation)
        Fu[0:nx, 0:ny3] = u1; Fv[0:nx, 0:ny3] = v1
        Fu[nx:2*nx, 0:ny3] = u2; Fv[nx:2*nx, 0:ny3] = v2

        # Face 3 halves (rotated)
        top_u = np.rot90(u3[0:(nx // 2), :], 1)
        top_v = np.rot90(v3[0:(nx // 2), :], 1)
        top_u, top_v = _rotvec(top_u, top_v, 1)
        Fu[0:nx, ny3:ny3 + nx // 2] = top_u
        Fv[0:nx, ny3:ny3 + nx // 2] = top_v

        bot_u = np.rot90(u3[(nx // 2):nx, :], 3)
        bot_v = np.rot90(v3[(nx // 2):nx, :], 3)
        bot_u, bot_v = _rotvec(bot_u, bot_v, 3)
        Fu[2*nx:3*nx, ny3:ny3 + nx // 2] = bot_u
        Fv[2*nx:3*nx, ny3:ny3 + nx // 2] = bot_v

        # Faces 8–10 and 11–13 (rotated 270° CW)
        blk_u = np.rot90(u4, 3); blk_v = np.rot90(v4, 3)
        blk_u, blk_v = _rotvec(blk_u, blk_v, 3)
        Fu[2*nx:3*nx, 0:ny3] = blk_u; Fv[2*nx:3*nx, 0:ny3] = blk_v

        blk_u = np.rot90(u5, 3); blk_v = np.rot90(v5, 3)
        blk_u, blk_v = _rotvec(blk_u, blk_v, 3)
        Fu[3*nx:4*nx, 0:ny3] = blk_u; Fv[3*nx:4*nx, 0:ny3] = blk_v
        return Fu, Fv

    def _c_to_t(Fu: np.ndarray, Fv: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Average U along x and V along y inside each face; leave seams NaN."""
        H, W = Fu.shape
        nx = H // 4
        ny3 = 3 * nx
        Uc = np.full_like(Fu, np.nan)
        Vc = np.full_like(Fv, np.nan)

        def ax_x(out, src, i_s, j_s):
            blk = src[i_s, j_s]; o = out[i_s, j_s]
            o[:, 1:] = 0.5 * (blk[:, 1:] + blk[:, :-1])

        def ax_y(out, src, i_s, j_s):
            blk = src[i_s, j_s]; o = out[i_s, j_s]
            o[1:, :] = 0.5 * (blk[1:, :] + blk[:-1, :])

        for r0 in (0, nx, 2*nx, 3*nx):
            i = slice(r0, r0 + nx)
            ax_y(Vc, Fv, i, slice(0, ny3))
            for c0 in (0, nx, 2*nx):
                j = slice(c0, c0 + nx)
                ax_x(Uc, Fu, i, j)

        j_side = slice(ny3, ny3 + nx // 2)
        for r0 in (0, 2*nx):
            i = slice(r0, r0 + nx)
            ax_x(Uc, Fu, i, j_side)
            ax_y(Vc, Fv, i, j_side)

        return Uc, Vc

    # ---- build mosaics exactly like plot() ----
    U = _as2d(u, k_index)
    V = _as2d(v, k_index)
    if mask_zeros:
        U = U.astype(float); V = V.astype(float)
        U[U == 0] = np.nan; V[V == 0] = np.nan

    Fu, Fv = _mosaic_vector(U, V)
    Uc, Vc = _c_to_t(Fu, Fv)  # T-point vectors, same mosaic shape as plot()

    # Optional: pad right to make a square canvas (width = 4*nx), if desired
    if pad_to_square:
        H, W = Uc.shape           # H = 4*nx, W = 3*nx + nx//2
        if W < H:
            pad = H - W
            Uc = np.pad(Uc, ((0,0),(0,pad)), constant_values=np.nan)
            Vc = np.pad(Vc, ((0,0),(0,pad)), constant_values=np.nan)
            Fu = np.pad(Fu, ((0,0),(0,pad)), constant_values=np.nan)
            Fv = np.pad(Fv, ((0,0),(0,pad)), constant_values=np.nan)

    # Background (|U|)
    im = None
    Fbg = None
    if show_background:
        Fbg = np.hypot(Uc, Vc)
        M = np.ma.masked_where(np.isnan(Fbg) | (Fbg == 0), Fbg)
        cmap_obj = plt.get_cmap(cmap).copy()
        cmap_obj.set_bad(color="white", alpha=1.0)
        im = ax.imshow(
            M.T,
            origin="lower",
            interpolation="nearest",
            aspect="equal",
            resample=False,
            cmap=cmap_obj,
            vmin=bg_vmin,          # <-- caxis (optional; raw values)
            vmax=bg_vmax
        )

    # --- Quiver (transpose to align with imshow(... .T ...)) ---
    q = None
    if draw_arrows:
        mask = np.isnan(Uc) | np.isnan(Vc) | ((Uc == 0) & (Vc == 0))
        UU = np.ma.array(Uc.T, mask=mask.T)
        VV = np.ma.array(Vc.T, mask=mask.T)

        # grid in image coords
        nrows, ncols = UU.shape  # height, width in display space
        X, Y = np.meshgrid(np.arange(ncols), np.arange(nrows))

        # Auto scale so arrows aren’t dots (based on raw values; not normalizing)
        if scale is None or (isinstance(scale, str) and str(scale).lower() == "auto"):
            spd = np.hypot(Uc, Vc)
            s = np.nanpercentile(spd, 90)
            desired_px = 10
            scale_eff = (s / desired_px) if np.isfinite(s) and s > 0 else 1.0
        else:
            scale_eff = float(scale)

        q = ax.quiver(
            X[::step, ::step], Y[::step, ::step],
            UU[::step, ::step], VV[::step, ::step],
            angles="xy", scale_units="xy", scale=scale_eff,
            pivot="mid", color=quiver_color,
            width=0.003, headwidth=4.5, headlength=6.0,
            zorder=10,
        )

        # Make sure the view actually covers the mosaic extents
        ax.set_xlim(0, ncols - 1)
        ax.set_ylim(0, nrows - 1)

    ax.set_aspect("equal")
    ax.set_xticks([]); ax.set_yticks([])

    return im, q, {"Fu": Fu, "Fv": Fv, "Uc": Uc, "Vc": Vc, "Fbg": Fbg}


__all__ = ["plot", "plot_llc_vector_cgrid"]
