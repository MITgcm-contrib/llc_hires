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
    Tile the 5 faces of an LLC slice into a full mosaic (8*nx x 13*8*nx).
    Face ordering as in MITgcm: 1,2,3,4,5 in columns.
    """
    repeat = 8
    NX = nx * repeat
    mosaic = np.zeros((NX, 13*NX), dtype=fld.dtype)

    # Face 1: columns 0 -> 3*nx
    src = fld[:, 0:3*nx]
    TMP = np.zeros((NX, 3*NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP[i::repeat, j::repeat] = src
    mosaic[:, 0:3*NX] = TMP

    # Face 2: columns 3*nx -> 6*nx
    src = fld[:, 3*nx:6*nx]
    TMP.fill(0)
    for i in range(repeat):
        for j in range(repeat):
            TMP[i::repeat, j::repeat] = src
    mosaic[:, 3*NX:6*NX] = TMP

    # Face 3: columns 6*nx -> 7*nx
    src = fld[:, 6*nx:7*nx]
    TMP = np.zeros((NX, NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP[i::repeat, j::repeat] = src
    mosaic[:, 6*NX:7*NX] = TMP

    # Face 4: reshape block then tile
    block = fld[:, 7*nx:10*nx].reshape((3*nx, nx), order='F')
    TMP = np.zeros((3*NX, NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP[i::repeat, j::repeat] = block
    mosaic[:, 7*NX:10*NX] = TMP.reshape((NX, 3*NX), order='F')

    # Face 5: reshape block then tile
    block = fld[:, 10*nx:13*nx].reshape((3*nx, nx), order='F')
    TMP = np.zeros((3*NX, NX), dtype=fld.dtype)
    for i in range(repeat):
        for j in range(repeat):
            TMP[i::repeat, j::repeat] = block
    mosaic[:, 10*NX:13*NX] = TMP.reshape((NX, 3*NX), order='F')

    return mosaic


def write_bin(fname, data, append=False):
    """
    Write `data` (big-endian float32) to `fname`. If append=True, append file.
    Data is flattened in Fortran order to match MATLAB.
    """
    mode = 'ab' if append else 'wb'
    with open(fname, mode) as f:
        f.write(data.astype('>f4').tobytes(order='F'))


def main():
    nx = 1080
    nz = 173
    pin = '/scratch/dmenemen/MITgcm/run_1080_hr162_dy020/'
    suf = '.0000019200.data'
    template_theta = '/scratch/dmenemen/llc1080_template/THETA_1jan23_v4r5_on_LLC1080.bin'
    template_salt = '/scratch/dmenemen/llc1080_template/SALT_1jan23_v4r5_on_LLC1080.bin'

    # 3D fields
    vars3d = ['Salt', 'Theta']
    for name in vars3d:
        print(f"Processing {name} (3D)")
        out_file = f"crood_llc8640_day20_no_low_cap_{name}"
        for k in range(1, nz+1):
            fld = quikread_llc(os.path.join(pin, name + suf), nx, k)
            if name == 'Theta':
                fld = fld.copy()
                fld2 = quikread_llc(template_theta, nx, k)
                mask0 = (fld == 0)
                fld[mask0] = fld2[mask0]
                fld[fld == 0] = 0.001
            if name == 'Salt':
                fld = fld.copy()
                fld2 = quikread_llc(template_salt, nx, k)
                mask0 = (fld == 0)
                fld[mask0] = fld2[mask0]
                fld[fld == 0] = 0.001
            mosaic = assemble_mosaic(fld, nx)
            write_bin(out_file, mosaic, append=(k > 1))

if __name__ == '__main__':
    main()