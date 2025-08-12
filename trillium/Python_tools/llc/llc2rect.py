import numpy as np

def llc2rect(LLC: np.ndarray) -> np.ndarray:
    """
    Convert an LLC mosaic (NX x 13*NX) to a 4NX x 4NX rectangular layout,
    matching MATLAB llc2rect.m (float64 output).
    """
    if LLC.ndim != 2:
        raise ValueError("LLC must be a 2D array")
    NX, NY = LLC.shape
    if NY != 13 * NX:
        raise ValueError(f"Expected LLC.shape[1] == 13*NX; got NX={NX}, NY={NY}")

    RECT = np.zeros((NX * 4, NX * 4), dtype=np.float64)

    # Top band: faces 1–3
    RECT[0:NX, 0:3*NX] = LLC[:, 0:3*NX]

    # Second band: faces 4–6 (left 3*NX) and face 7 (rightmost NX)
    RECT[NX:2*NX, 0:3*NX] = LLC[:, 3*NX:6*NX]
    RECT[NX:2*NX, 3*NX:4*NX] = LLC[:, 6*NX:7*NX]

    # Third band: faces 8–10 -> flipud(reshape(...))'
    blk = LLC[:, 7*NX:10*NX]                      # (NX, 3*NX)
    tmp = blk.reshape((3*NX, NX), order="F").T    # (NX, 3*NX) == reshape(... )'
    RECT[2*NX:3*NX, 0:3*NX][:, ::-1] = tmp        # flip columns after transpose

    # Fourth band: faces 11–13 -> same
    blk = LLC[:, 10*NX:13*NX]
    tmp = blk.reshape((3*NX, NX), order="F").T
    RECT[3*NX:4*NX, 0:3*NX][:, ::-1] = tmp

    return RECT
