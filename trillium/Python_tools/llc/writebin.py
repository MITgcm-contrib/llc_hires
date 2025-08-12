import os
from typing import Any, Tuple
import numpy as np

def writebin(
    fnam: str,
    fld: Any,
    typ: int = 1,
    prec: str = "real*4",
    skip: int = 0,
    mform: str = "ieee-be",
) -> None:
    """
    Python port of writebin.m (bit-identical).
    typ=0 writes one Fortran unformatted record; typ=1 writes plain binary.
    """
    prec_norm_map = {
        "integer*1": "int8", "integer*2": "int16", "integer*4": "int32", "integer*8": "int64",
        "real*4": "single", "float32": "single", "real*8": "double", "float64": "double",
        "int8": "int8", "int16": "int16", "uint16": "uint16",
        "int32": "int32", "uint32": "uint32", "single": "single",
        "int64": "int64", "uint64": "uint64", "double": "double",
    }
    if prec.lower() not in prec_norm_map:
        raise ValueError(f"Unsupported precision: {prec}")
    prec_norm = prec_norm_map[prec.lower()]

    base_to_np: dict[str, Tuple[str, int]] = {
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

    arr = np.asarray(fld)
    arr_for_file = arr.astype(dtype_file, copy=False)
    nbytes_payload = int(arr_for_file.size) * elsize

    if os.path.exists(fnam):
        f = open(fnam, "r+b")
    else:
        f = open(fnam, "w+b")

    try:
        if typ == 0:
            if skip > 0:
                raise NotImplementedError("feature not implemented yet")  # matches MATLAB
            reclen_dtype = np.dtype(endian + "i4")
            f.write(np.array([nbytes_payload], dtype=reclen_dtype).tobytes())
            f.write(arr_for_file.tobytes(order="F"))
            f.write(np.array([nbytes_payload], dtype=reclen_dtype).tobytes())

        elif typ == 1:
            if skip == 0:
                f.write(arr_for_file.tobytes(order="F"))
            else:
                reclength = nbytes_payload
                target = skip * reclength
                f.seek(0, os.SEEK_END)
                file_length = f.tell()
                if target <= file_length:
                    f.seek(target, os.SEEK_SET)
                    f.write(arr_for_file.tobytes(order="F"))
                else:
                    f.seek(0, os.SEEK_END)
                    gap = target - file_length
                    if gap > 0:
                        f.write(b"\x00" * gap)
                    f.write(arr_for_file.tobytes(order="F"))
        else:
            raise ValueError("typ must be 0 (Fortran sequential) or 1 (plain binary)")
    finally:
        f.close()
