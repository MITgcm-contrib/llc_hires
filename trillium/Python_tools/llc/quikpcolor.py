import numpy as np
import matplotlib.pyplot as plt
import warnings
from typing import Optional, Tuple

def _is_uniform(vec: np.ndarray) -> bool:
    vec = np.asarray(vec)
    if vec.size < 2:
        return True
    d = np.diff(vec.astype(np.float64, copy=False))
    return np.all(d == d[0])

def _uniform_axis(v: np.ndarray) -> Tuple[np.ndarray, float]:
    """Replicate MATLAB-ish: dx = min(v):min(abs(diff(v))):max(v) (inclusive-ish)."""
    v = np.asarray(v, dtype=np.float64)
    step = np.min(np.abs(np.diff(v))) if v.size > 1 else 1.0
    vmin, vmax = float(v.min()), float(v.max())
    out = np.arange(vmin, vmax + 0.5 * step, step, dtype=np.float64)
    return out, step

def _bilinear_grid(x: np.ndarray, y: np.ndarray, z: np.ndarray,
                   xi: np.ndarray, yi: np.ndarray) -> np.ndarray:
    """
    Fast bilinear on a tensor-product grid:
      x: (nx,), y: (ny,), z: (ny, nx)
      xi: (N,), yi: (M,)  -> returns (M, N).
    """
    x = np.asarray(x, dtype=np.float64)
    y = np.asarray(y, dtype=np.float64)
    z = np.asarray(z, dtype=np.float64)

    # Ensure increasing axes (flip if necessary)
    x_flip = x[0] > x[-1]
    y_flip = y[0] > y[-1]
    if x_flip:
        x = x[::-1]; z = z[:, ::-1]
    if y_flip:
        y = y[::-1]; z = z[::-1, :]

    xi = np.asarray(xi, dtype=np.float64)
    yi = np.asarray(yi, dtype=np.float64)
    xi = np.clip(xi, x[0], x[-1])
    yi = np.clip(yi, y[0], y[-1])

    ix = np.searchsorted(x, xi, side="right") - 1
    iy = np.searchsorted(y, yi, side="right") - 1
    ix = np.clip(ix, 0, x.size - 2)
    iy = np.clip(iy, 0, y.size - 2)

    x0 = x[ix]; x1 = x[ix + 1]
    y0 = y[iy]; y1 = y[iy + 1]
    with np.errstate(divide="ignore", invalid="ignore"):
        tx = (xi - x0) / (x1 - x0)
        ty = (yi - y0) / (y1 - y0)
    tx = np.nan_to_num(tx); ty = np.nan_to_num(ty)

    IY, IX = np.meshgrid(iy, ix, indexing="ij")
    z00 = z[IY, IX]
    z10 = z[IY, IX + 1]
    z01 = z[IY + 1, IX]
    z11 = z[IY + 1, IX + 1]

    Tx = tx[np.newaxis, :]
    Ty = ty[:, np.newaxis]
    out = ((1 - Tx) * (1 - Ty) * z00 +
           Tx       * (1 - Ty) * z10 +
           (1 - Tx) * Ty       * z01 +
           Tx       * Ty       * z11)
    return out

def quikpcolor(*args, ax: Optional[plt.Axes] = None, relaxed: bool = False):
    """
    quikpcolor(x) or quikpcolor(x,y,z), optimized.

    Bit-identical branches:
      - quikpcolor(x)
      - quikpcolor(x,y,z) with uniform spacing in x and y

    Non-uniform branch:
      - If relaxed=True, uses fast bilinear interpolation to a uniform grid
        (very close but NOT bit-identical to MATLAB). Emits a warning.
      - If relaxed=False, raises NotImplementedError.
    """
    if ax is None:
        ax = plt.gca()

    if len(args) == 1:
        x = np.asarray(args[0])
        im = ax.imshow(x, origin="lower", interpolation="nearest", aspect="auto")
        return im

    if len(args) != 3:
        raise TypeError("quikpcolor expects 1 or 3 positional arguments")

    x, y, z = (np.asarray(a) for a in args)
    if z.shape != (y.size, x.size):
        raise ValueError(f"z must have shape (len(y), len(x)); got {z.shape} vs {(y.size, x.size)}")

    if _is_uniform(x) and _is_uniform(y):
        extent = (float(x.min()), float(x.max()), float(y.min()), float(y.max()))
        im = ax.imshow(z, origin="lower", interpolation="nearest", aspect="auto", extent=extent)
        return im

    if not relaxed:
        raise NotImplementedError(
            "Non-uniform x,y not supported under bit-identity constraints. "
            "Pass relaxed=True to use a fast bilinear path (not bit-identical)."
        )

    warnings.warn(
        "relaxed=True: using fast bilinear interpolation for non-uniform x,y. "
        "Output will NOT be bit-identical to MATLAB.",
        UserWarning,
        stacklevel=2,
    )

    xi, _ = _uniform_axis(x)
    yi, _ = _uniform_axis(y)
    dz = _bilinear_grid(x, y, z, xi, yi)

    extent = (float(xi.min()), float(xi.max()), float(yi.min()), float(yi.max()))
    im = ax.imshow(dz, origin="lower", interpolation="nearest", aspect="auto", extent=extent)
    return im

# Backwards-compatible alias
quikpcolor_fast = quikpcolor
