import numpy as np
from quikread_llc import quikread_llc


def assemble_mosaic(fld, nx):
    """
    Given a 2D LLC field `fld` of shape (nx, 13*nx), assemble into
    the full mosaic of size (8*nx, 13*8*nx) by tiling each face.
    """
    repeat = 8
    NX = nx * repeat
    FLD = np.zeros((NX, 13 * NX), dtype=fld.dtype)

    # Face 1: columns 0 : 3*nx
    tmp = fld[:, 0 : nx * 3]
    m1 = np.repeat(np.repeat(tmp, repeat, axis=0), repeat, axis=1)
    FLD[:, 0 : 3 * NX] = m1

    # Face 2: columns 3*nx : 6*nx
    tmp = fld[:, nx * 3 : nx * 6]
    m2 = np.repeat(np.repeat(tmp, repeat, axis=0), repeat, axis=1)
    FLD[:, 3 * NX : 6 * NX] = m2

    # Face 3: columns 6*nx : 7*nx
    tmp = fld[:, nx * 6 : nx * 7]
    m3 = np.repeat(np.repeat(tmp, repeat, axis=0), repeat, axis=1)
    FLD[:, 6 * NX : 7 * NX] = m3

    # Face 4: reshape then tile, then reshape into mosaic block
    tmp = fld[:, nx * 7 : nx * 10].reshape((3 * nx, nx), order='F')
    t4 = np.repeat(np.repeat(tmp, repeat, axis=0), repeat, axis=1)
    m4 = t4.reshape((NX, 3 * NX), order='F')
    FLD[:, 7 * NX : 10 * NX] = m4

    # Face 5: same as face 4 but next columns
    tmp = fld[:, nx * 10 : nx * 13].reshape((3 * nx, nx), order='F')
    t5 = np.repeat(np.repeat(tmp, repeat, axis=0), repeat, axis=1)
    m5 = t5.reshape((NX, 3 * NX), order='F')
    FLD[:, 10 * NX : 13 * NX] = m5

    return FLD


def write_bin(fname, data, append=False):
    """
    Write `data` (NumPy array, dtype='>f4') to binary file `fname`.
    Uses Fortran (column-major) order to match MATLAB's fwrite.
    If append=True, opens in 'ab', else 'wb'.
    """
    mode = 'ab' if append else 'wb'
    with open(fname, mode) as f:
        f.write(data.tobytes(order='F'))


def main():
    nx = 1080
    nz = 173
    pin = '/scratch/dmenemen/MITgcm/run_1080_day017/'
    suf = '.0000057600.data'

    # Surface/state variables (no vertical levels)
    vars2d = ['Eta', 'SIarea', 'SIheff', 'SIhsalt', 'SIhsnow', 'SIuice', 'SIvice']
    for v in vars2d:
        print(f"Processing {v}...")
        fld = quikread_llc(f"{pin}{v}{suf}", nx)
        FLD = assemble_mosaic(fld, nx)
        write_bin(f"crood_llc8640_{v}", FLD.astype('>f4'), append=False)

    # 3D variables (loop over vertical levels)
    vars3d = ['Salt', 'Theta', 'U', 'V']
    for v in vars3d:
        print(f"Processing {v} (3D)...")
        outname = f"crood_llc8640_{v}"
        # overwrite or create new file for level 1
        for k in range(1, nz + 1):
            fld = quikread_llc(f"{pin}{v}{suf}", nx, k)
            FLD = assemble_mosaic(fld, nx)
            write_bin(outname, FLD.astype('>f4'), append=(k > 1))

if __name__ == '__main__':
    main()