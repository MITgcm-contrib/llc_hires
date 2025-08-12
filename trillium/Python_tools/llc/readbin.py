import os
from typing import Sequence
import numpy as np

def readbin(
    fnam: str,
    siz: Sequence[int] = (360, 224, 46),
    typ: int = 1,
    prec: str = "real*4",
    skip: int = 0,
    mform: str = "ieee-be",
) -> np.ndarray:
    """
    Python port of MATLAB readbin.m (bit-identical).
    """
    if not os.path.exists(fnam):
        raise FileNotFoundError(f"File {fnam} does not exist.")

    prec_norm_map = {
        "integer*1": "int8", "integer*2": "int16", "integer*4": "int32", "integer*8": "int64",
        "real*4": "single", "float32": "single", "real*8": "double", "float64": "double",
        "int8": "int8", "int16": "int16", "uint16": "uint16",
        "int32": "int32", "uint32": "uint32", "single": "single",
        "int64": "int64", "uint64": "uint64", "double": "double",
    }
    prec_l = prec.lower()
    if prec_l not in prec_norm_map:
        raise ValueError(f"Unsupported precision: {prec}")
    prec_norm = prec_norm_map[prec_l]

    base_to_np = {
        "int8": ("i1", 1),
        "int16": ("i2", 2), "uint16": ("u2", 2),
        "int32": ("i4", 4), "uint32": ("u4", 4), "single": ("f4", 4),
        "int64": ("i8", 8), "uint64": ("u8", 8), "double": ("f8", 8),
    }
    code, elsize = base_to_np[prec_norm]

    mform_l = (mform or "").lower()
    if "be" in mform_l: endian = ">"
    elif "le" in mform_l: endian = "<"
    else: endian = ">"
    dtype_file = np.dtype(endian + code)
    dtype_native = np.dtype(code).newbyteorder("=")

    def _prod(seq):
        p = 1
        for v in seq: p *= int(v)
        return p

    def _read_fortran_record(f):
        len_dtype = np.dtype(endian + "i4")
        buf = f.read(len_dtype.itemsize)
        if len(buf) != len_dtype.itemsize: raise EOFError("past end of file")
        (nbytes,) = np.frombuffer(buf, dtype=len_dtype, count=1)
        count = int(nbytes) // elsize
        data = np.fromfile(f, dtype=dtype_file, count=count)
        if data.size != count: raise EOFError("past end of file")
        buf2 = f.read(len_dtype.itemsize)
        if len(buf2) != len_dtype.itemsize: raise EOFError("past end of file")
        return data.astype(dtype_native, copy=False)

    siz = tuple(int(s) for s in siz)
    nelems = _prod(siz)

    with open(fnam, "rb") as f:
        if skip > 0:
            if typ == 0:
                for _ in range(int(skip)):
                    _ = _read_fortran_record(f)
            elif typ == 1:
                reclength = nelems * elsize
                target = skip * reclength
                f.seek(0, os.SEEK_END)
                file_len = f.tell()
                if target > file_len:
                    raise EOFError("past end of file")
                f.seek(target, os.SEEK_SET)
            else:
                raise ValueError("typ must be 0 or 1")

        if typ == 0:
            tmp = _read_fortran_record(f)
        else:
            cols = int(siz[0])
            rows = int(_prod(siz[1:])) if len(siz) > 1 else 1
            count = cols * rows
            data = np.fromfile(f, dtype=dtype_file, count=count)
            if data.size != count: raise EOFError("past end of file")
            tmp = data.astype(dtype_native, copy=False).reshape((cols, rows), order="F")

    if len(siz) == 1:
        fld = tmp.reshape(siz[0], order="F")
    else:
        fld = tmp.reshape(siz, order="F")
    return fld
