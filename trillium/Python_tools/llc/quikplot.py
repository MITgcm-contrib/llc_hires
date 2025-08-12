import numpy as np
import matplotlib.pyplot as plt
from typing import Optional
from .quikpcolor import quikpcolor

def quikplot(fld: np.ndarray, ax: Optional[plt.Axes] = None, k_index: int = 0):
    """
    Plot an LLC mosaic (full field).
    Accepts:
      - 2D array: (nx, 13*nx)
      - 3D array: (nx, 13*nx, k)  -> selects k_index
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

    im = quikpcolor(F.T, ax=ax)
    ax.set_xticks([]); ax.set_yticks([])
    return im, F
