import os
import numpy as np
from typing import Sequence, Optional, Union, List

def read_llc_fkij(
    fnam: str,
    nx: int = 270,
    face: int = 1,
    kx: Union[int, Sequence[int]] = 1,
    ix: Optional[Sequence[int]] = None,
    jx: Optional[Sequence[int]] = None,
    prec: str = "real*4",
) -> np.ndarray:
    """
    Fast + bit-identical port of MATLAB read_llc_fkij.m.
    Uses np.memmap + strided views (no per-row loops). 1-based ix/jx/kx.
    """
    # ---- normalize indices (MATLAB 1-based; contiguous required) ----
    def _to_list(v) -> List[int]:
        if v is None:
            return []
        if isinstance(v, (list, tuple, np.ndarray, range)):
            return [int(x) for x in v]
        return [int(v)]
    def _is_unit_stride(seq: List[int]) -> bool:
        return len(seq) <= 1 or all(seq[i+1] == seq[i] + 1 for i in range(len(seq)-1))

    if ix is None: ix = list(range(1, nx + 1))
    else: ix = _to_list(ix)
    if jx is None: jx = list(range(1, (nx if face == 3 else 3 * nx) + 1))
    else: jx = _to_list(jx)
    kx = _to_list(kx)

    if not _is_unit_stride(ix): raise ValueError("ix must be contiguous, unit-stride")
    if not _is_unit_stride(jx): raise ValueError("jx must be contiguous, unit-stride")

    # Reverse jx for faces 4 & 5 (exact MATLAB behavior)
    if face > 3:
        jx = [3 * nx + 1 - j for j in jx[::-1]]

    len_ix, len_jx, len_kx = len(ix), len(jx), len(kx)

    # ---- precision / dtype mapping ----
    prec_lut = {
        "integer*1": "int8", "integer*2": "int16", "integer*4": "int32", "integer*8": "int64",
        "real*4": "single", "float32": "single", "real*8": "double", "float64": "double",
        "int8": "int8", "int16": "int16", "uint16": "uint16",
        "int32": "int32", "uint32": "uint32", "single": "single",
        "int64": "int64", "uint64": "uint64", "double": "double",
    }
    prec_norm = prec_lut.get(prec.lower())
    if prec_norm is None:
        raise ValueError(f"Unsupported precision: {prec}")

    base_to_np = {
        "int8": ("i1", 1),
        "int16": ("i2", 2), "uint16": ("u2", 2),
        "int32": ("i4", 4), "uint32": ("u4", 4), "single": ("f4", 4),
        "int64": ("i8", 8), "uint64": ("u8", 8), "double": ("f8", 8),
    }
    code, preclength = base_to_np[prec_norm]
    dtype_be = np.dtype(">" + code)                     # on-disk big-endian
    dtype_native = np.dtype(code).newbyteorder("=")     # returned dtype

    # EOF safety (mimic MATLAB fseek failure)
    len_kx_tmp = len(kx)
    max_k = max(kx) if len_kx_tmp else 1
    need_bytes = max_k * nx * nx * 13 * preclength
    have_bytes = os.path.getsize(fnam)
    if need_bytes > have_bytes:
        raise EOFError("past end of file")

    # ---- memmap whole file (read-only) ----
    mm = np.memmap(fnam, dtype=dtype_be, mode="r")

    # allocate output
    fld = np.zeros((len_ix, len_jx, len_kx), dtype=dtype_native)

    for kk, klev in enumerate(kx):
        level_off = (klev - 1) * nx * nx * 13  # element offset to this level

        if face in (1, 2, 3):
            # Level as (nx, nx*13) in Fortran layout
            lvl = np.ndarray(
                shape=(nx, nx * 13),
                dtype=dtype_be,
                buffer=mm,
                offset=level_off * preclength,
                strides=(preclength, preclength * nx),
            )
            j0 = (face - 1) * 3 * nx + (jx[0] - 1)
            sub = lvl[(ix[0]-1):(ix[0]-1+len_ix), j0:(j0+len_jx)]
            fld[:, :, kk] = sub.astype(dtype_native, copy=False)

        elif face in (4, 5):
            # Face 4 starts at block 7, face 5 at block 10 within the k-level
            face_block0 = 7 if face == 4 else 10
            face_off = level_off + face_block0 * nx * nx

            face2d = np.ndarray(
                shape=(3 * nx, nx),  # (j, i)
                dtype=dtype_be,
                buffer=mm,
                offset=face_off * preclength,
                strides=(preclength, preclength * 3 * nx),
            )
            A = face2d[(jx[0]-1):(jx[0]-1+len_jx), (ix[0]-1):(ix[0]-1+len_ix)]
            tmp = np.rot90(A, 3)
            fld[:, :, kk] = tmp.astype(dtype_native, copy=False)

        else:
            raise ValueError("face must be in 1..5")

    del mm
    return fld
