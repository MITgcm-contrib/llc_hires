import numpy as np

import os


def quikread_llc(fname, nx, k=None, prec='>f4'):
    """
    Read an LLC binary file (big-endian real*4) of shape (nx, nx*13, levels).

    Parameters
    ----------
    fname : str
        Path to .data file containing concatenated levels.
    nx : int
        Tile dimension (e.g., 1080).
    k : int, optional
        1-based level index to read. If None, defaults to 1.
    prec : str, optional
        NumPy dtype descriptor, default big-endian float32.

    Returns
    -------
    fld : ndarray, shape (nx, 13*nx)
        Field at level k.
    """
    dtype = np.dtype(prec)
    count_per_level = nx * nx * 13
    bytes_per_level = count_per_level * dtype.itemsize

    level = 1 if k is None else int(k)
    with open(fname, 'rb') as f:
        f.seek((level - 1) * bytes_per_level, os.SEEK_SET)
        raw = f.read(bytes_per_level)
        arr = np.frombuffer(raw, dtype=prec)
        fld = arr.reshape((nx, 13*nx), order='F')
    return fld

def assemble_mosaic(fld, nx):
    """
    Assemble an LLC tile field `fld` of shape (nx, 13*nx) into
    the full mosaic of size (8*nx, 13*8*nx) matching MATLAB's tiling.
    """
    repeat = 8
    NX = nx * repeat
    mosaic = np.zeros((NX, 13 * NX), dtype=fld.dtype)

    # Helper for block tiling
    def tile_block(src, out_shape, start_col, block_width):
        TMP = np.zeros(out_shape, dtype=fld.dtype)
        for i in range(repeat):
            for j in range(repeat):
                TMP[i::repeat, j::repeat] = src
        mosaic[:, start_col:start_col+block_width] = TMP

    # Tile 1 (cols 0:3*nx)
    src1 = fld[:, 0:nx*3]
    tile_block(src1, (NX, 3*NX), 0, 3*NX)

    # Tile 2 (cols 3*nx:6*nx)
    src2 = fld[:, nx*3:nx*6]
    tile_block(src2, (NX, 3*NX), 3*NX, 3*NX)

    # Tile 3 (cols 6*nx:7*nx)
    src3 = fld[:, nx*6:nx*7]
    tile_block(src3, (NX, NX), 6*NX, NX)

    # Tile 4 (reshape then tile, then reshape out)
    t4 = fld[:, nx*7:nx*10].reshape((3*nx, nx), order='F')
    TMP4 = np.zeros((NX*3, NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP4[i::repeat, j::repeat] = t4
    block4 = TMP4.reshape((NX, 3*NX), order='F')
    mosaic[:, 7*NX:10*NX] = block4

    # Tile 5 (same as tile 4)
    t5 = fld[:, nx*10:nx*13].reshape((3*nx, nx), order='F')
    TMP5 = np.zeros((NX*3, NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP5[i::repeat, j::repeat] = t5
    block5 = TMP5.reshape((NX, 3*NX), order='F')
    mosaic[:, 10*NX:13*NX] = block5

    return mosaic


def write_bin(fname, data, append=False):
    """
    Write a 2D array `data` (dtype='>f4') to binary file `fname` in Fortran order.
    If append=True, appends; otherwise, overwrites.
    """
    mode = 'ab' if append else 'wb'
    with open(fname, mode) as f:
        f.write(data.tobytes(order='F'))


def main():
    nx = 1080
    nz = 173
    pin = '/scratch/dmenemen/MITgcm/run_1080_hr162_dy020/'
    suf = '.0000019200.data'

    # 2D variables
    vars2d = ['Eta', 'SIarea', 'SIheff', 'SIhsalt', 'SIhsnow', 'SIuice', 'SIvice']
    for v in vars2d:
        print(f"Processing {v} (2D)...")
        fld = quikread_llc(f"{pin}{v}{suf}", nx)
        mosaic = assemble_mosaic(fld, nx)
        write_bin(f"crood_llc8640_day20_no_low_cap_{v}", mosaic.astype('>f4'), append=False)

    # 3D variables
    vars3d = ['U', 'V']
    for v in vars3d:
        print(f"Processing {v} (3D)...")
        outname = f"crood_llc8640_day20_no_low_cap_{v}"
        for k in range(1, nz+1):
            fld = quikread_llc(f"{pin}{v}{suf}", nx, k)
            mosaic = assemble_mosaic(fld, nx)
            write_bin(outname, mosaic.astype('>f4'), append=(k > 1))

if __name__ == '__main__':
    main()