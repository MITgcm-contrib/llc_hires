# llc_view — quick viewer for LLC tracer & vector C-grid data

Short guide to run the script `vis_llc.py` and understand the options.

## Requirements
- Python 3.8+
- `matplotlib`, `numpy`
- `llc` Python module available on your `PYTHONPATH`
- For interactive plots from a remote **cluster**, enable **X11 forwarding**: run an X server on your local machine (macOS: XQuartz; Windows: VcXsrv/Xming or Windows 11 WSLg; Linux: native X11), then SSH with trusted forwarding and compression, e.g. `ssh -Y -C user@cluster`. The cluster must allow X11 forwarding (`X11Forwarding yes`) and have `xauth` installed.

## Quick start
```bash
# Tracer (one file)
python vis_llc.py temp.data --nx 90 --level 1 --cmap Blues --vmin -2 --vmax 30

# Vector (two files: U then V)
python vis_llc.py U.data V.data --nx 90 --level 1 --mode both --cmap viridis --vmin 0 --vmax 2

# Arrows-only, sparse quiver, white arrows
python vis_llc.py U.data V.data --nx 1080 --level 5 --mode arrows --quiver-step 10 --quiver-color white

# Save to PNG without showing a window
python vis_llc.py temp.data --nx 8640 --no-show -o out.png
```

## Usage
```text
python vis_llc.py FILE [FILE] --nx NX [options]
```
- **FILE**: 1 file → tracer; 2 files (`U V`) → vector field.
- **--nx**: tile dimension (e.g., 90, 1080, etc.). Required.

## Options (common)
- `--level INT` — Vertical level (1‑based). Default: `1`.
- `--prec STR` — Precision for `llc.quikread` (e.g., `real*4`, `real*8`). Default: `real*4`.
- `--cmap NAME` — Matplotlib colormap for the image. Default: `viridis`.
- `--vmin FLOAT` / `--vmax FLOAT` — Color limits (raw values). If omitted, auto.
- `-o, --output PATH` — Save PNG to this path.
- `--no-show` — Do not open a window; just save.
- `--dock-pad INT` — Bottom padding (px) when sizing the window. Default `100` (or env `DOCK_PAD_PX`).
- `--pad-to-square` — Pads right side so width≈`4*nx` for a square canvas.
- `--no-mask-zeros` — Keep zeros visible (by default zeros are masked).

## Options (vectors only)
- `--mode {bg,arrows,both}` — Show colored magnitude background, arrows only, or both. Default: `both`.
- `--quiver-step INT` — Subsample factor for arrows (larger → fewer arrows). Default: `8`.
- `--quiver-scale FLOAT|auto` — Arrow scale. Omit or use `auto` for automatic.
- `--quiver-color NAME` — Arrow color. Default: `black`.

## Title (optional time origin)
If you pass **all four** of `--startyr --startmo --startdy --deltaT` **and** the first input filename matches `*##########.data` (10‑digit timestamp), the title is set to:
```
llc.ts2dte(ts, deltat=deltaT, startyr=..., startmo=..., startdy=...)
```

## Interaction
- **Hover**: shows raw value at cursor (tracer value or `sqrt(U^2+V^2)` (speed) for vectors).
- **Click**: prints `x	y	value`.
- **Keys**: `q` or `Esc` = close; `f` = refit window to work area.
