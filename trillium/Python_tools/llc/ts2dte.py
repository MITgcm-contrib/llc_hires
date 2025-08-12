from datetime import datetime, timedelta
from typing import Union, Sequence, List
import re
import numpy as np

def ts2dte(
    ts: Union[int, float, Sequence[Union[int, float]], np.ndarray],
    deltat: Union[int, float] = 1200,
    startyr: int = 1992,
    startmo: int = 1,
    startdy: int = 1,
    form: Union[int, str] = -1,
):
    """
    Convert model time step(s) to date string(s), mirroring MATLAB ts2dte.m.
    """
    is_scalar = not isinstance(ts, (list, tuple, np.ndarray))
    ts_list = [ts] if is_scalar else list(ts)

    if isinstance(form, int):
        if form == -1:
            fmt = "dd-mmm-yyyy HH:MM:SS"
        else:
            raise ValueError("Only numeric form == -1 is supported. "
                             "Pass a MATLAB-style format string for other formats.")
    else:
        fmt = str(form)

    base = datetime(startyr, startmo, startdy)

    MONTH_ABBR = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    MONTH_FULL = ["January","February","March","April","May","June",
                  "July","August","September","October","November","December"]
    WD_ABBR = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    WD_FULL = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]

    token_re = re.compile(r"yyyy|mmmm|mmm|mm|dddd|ddd|dd|HH|hh|MM|SS|AM|PM|am|pm|yy")

    def format_matlab_datestr(dt: datetime, fmt: str) -> str:
        def repl(m: re.Match) -> str:
            t = m.group(0)
            if t == "yyyy": return f"{dt.year:04d}"
            if t == "yy":   return f"{dt.year % 100:02d}"
            if t == "mmmm": return MONTH_FULL[dt.month - 1]
            if t == "mmm":  return MONTH_ABBR[dt.month - 1]
            if t == "mm":   return f"{dt.month:02d}"
            if t == "dddd": return WD_FULL[dt.weekday()]
            if t == "ddd":  return WD_ABBR[dt.weekday()]
            if t == "dd":   return f"{dt.day:02d}"
            if t == "HH":   return f"{dt.hour:02d}"
            if t == "hh":
                h = dt.hour % 12
                if h == 0: h = 12
                return f"{h:02d}"
            if t == "MM":   return f"{dt.minute:02d}"
            if t == "SS":   return f"{dt.second:02d}"
            if t in ("AM","PM"): return "AM" if dt.hour < 12 else "PM"
            if t in ("am","pm"): return "am" if dt.hour < 12 else "pm"
            return t
        return token_re.sub(repl, fmt)

    out: List[str] = []
    for t in ts_list:
        dt = base + timedelta(seconds=float(t) * float(deltat))
        out.append(format_matlab_datestr(dt, fmt))

    return out[0] if is_scalar else out
