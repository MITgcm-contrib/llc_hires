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

def llc2rect_nd(LLC: np.ndarray) -> np.ndarray:
    """
    Vectorized LLC->rect transform.
    - If LLC has shape (NX, 13*NX), returns (4*NX, 4*NX).
    - If LLC has shape (NX, 13*NX, K), returns (4*NX, 4*NX, K).
    Matches MATLAB llc2rect.m layout; output is float64.
    """
    if LLC.ndim not in (2, 3):
        raise ValueError("LLC must be a 2D or 3D array")

    # Normalize to 3D: (NX, 13*NX, K) where K=1 for 2D input
    orig_2d = (LLC.ndim == 2)
    if orig_2d:
        LLC = LLC[..., None]

    NX, NY, K = LLC.shape
    if NY != 13 * NX:
        raise ValueError(f"Expected LLC.shape[1] == 13*NX; got NX={NX}, NY={NY}")

    RECT = np.zeros((4*NX, 4*NX, K), dtype=np.float64)

    # Top band: faces 1–3
    RECT[0:NX, 0:3*NX, :] = LLC[:, 0:3*NX, :]

    # Second band: faces 4–6 (left) and 7 (rightmost)
    RECT[NX:2*NX, 0:3*NX, :] = LLC[:, 3*NX:6*NX, :]
    RECT[NX:2*NX, 3*NX:4*NX, :] = LLC[:, 6*NX:7*NX, :]

    # Third band: faces 8–10 -> flipud(reshape(...))' per k, vectorized
    blk = np.asfortranarray(LLC[:, 7*NX:10*NX, :])           # (NX, 3*NX, K), Fortran layout
    tmp = blk.reshape((3*NX, NX, K), order="F").transpose(1, 0, 2)  # (NX, 3*NX, K)
    RECT[2*NX:3*NX, 0:3*NX, :] = tmp[:, ::-1, :]             # flip columns

    # Fourth band: faces 11–13 -> same
    blk = np.asfortranarray(LLC[:, 10*NX:13*NX, :])          # (NX, 3*NX, K)
    tmp = blk.reshape((3*NX, NX, K), order="F").transpose(1, 0, 2)  # (NX, 3*NX, K)
    RECT[3*NX:4*NX, 0:3*NX, :] = tmp[:, ::-1, :]

    # Return 2D if input was 2D
    return RECT[..., 0] if orig_2d else RECT