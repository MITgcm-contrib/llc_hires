import numpy as np


def quikread_llc(fname, nx, k=None, prec='>f4'):
    """
    Read an LLC binary field from file `fname`.

    Parameters
    ----------
    fname : str
        Path to binary file.
    nx : int
        Tile dimension (e.g., 1080).
    k : int or sequence of ints, optional
        Vertical level(s) to read (1-based). If None, defaults to level 1.
    prec : str, optional
        NumPy dtype string for data precision; default is '>f4' (big-endian real*4).

    Returns
    -------
    fld : ndarray
        2D array (nx, 13*nx) if one level is requested, or
        3D array (nx, 13*nx, len(k)) if multiple levels.
    """
    dtype = np.dtype(prec)
    preclength = dtype.itemsize
    tile_count = 13
    total = nx * nx * tile_count

    # Determine levels to read
    if k is None:
        levels = [1]
    elif isinstance(k, int):
        levels = [k]
    else:
        levels = list(k)

    arrs = []
    with open(fname, 'rb') as f:
        for lev in levels:
            # skip preceding levels
            offset = (lev - 1) * total * preclength
            f.seek(offset, 0)
            # read one 2D slice
            raw = f.read(total * preclength)
            data = np.frombuffer(raw, dtype=prec)
            # reshape using column-major order to match MATLAB
            data = data.reshape((nx, tile_count * nx), order='F')
            arrs.append(data)

    if len(arrs) == 1:
        return arrs[0]
    else:
        return np.stack(arrs, axis=2)