import numpy as np

def rect2llc(RECT: np.ndarray) -> np.ndarray:
    """
    Convert a 4NX x 4NX rectangular mosaic back to an LLC field (NX x 13*NX),
    matching MATLAB rect2llc.m exactly (float64 output).
    """
    if RECT.ndim != 2:
        raise ValueError("RECT must be a 2D array")

    nx, ny = RECT.shape
    if nx % 4 != 0:
        raise ValueError(f"RECT.shape[0] must be divisible by 4; got {nx}")
    NX = nx // 4
    if ny != 4 * NX:
        raise ValueError(f"Expected RECT.shape[1] == {4*NX}; got {ny}")

    LLC = np.zeros((NX, NX * 13), dtype=np.float64)

    # Faces 1–7 (straight copies)
    LLC[:, 0:3*NX]       = RECT[0:NX,       0:3*NX]
    LLC[:, 3*NX:6*NX]    = RECT[NX:2*NX,    0:3*NX]
    LLC[:, 6*NX:7*NX]    = RECT[NX:2*NX,  3*NX:4*NX]

    # Faces 8–10: LLC(:,7*NX:10*NX) = reshape(flipud(R'), NX, 3*NX)
    R = RECT[2*NX:3*NX, 0:3*NX]              # (NX, 3*NX)
    Q = np.flipud(R.T)                        # (3*NX, NX)
    LLC[:, 7*NX:10*NX] = Q.reshape((NX, 3*NX), order="F")

    # Faces 11–13
    R = RECT[3*NX:4*NX, 0:3*NX]
    Q = np.flipud(R.T)
    LLC[:, 10*NX:13*NX] = Q.reshape((NX, 3*NX), order="F")

    return LLC
