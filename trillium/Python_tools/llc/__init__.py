"""
llc: Unified toolbox that re-exports convenience functions from bundled modules.

Available top-level functions:
quikplot_llc, read_llc_fkij, rect2llc, writebin, ts2dte, quikread_llc, llc2rect, quikpcolor, readbin

Example:
    import llc
    arr = llc.readbin("file.bin", nx=90, ny=1170, dtype=">f4")
"""
from .quikplot import quikplot
from .plot import plot
from .plot import plot_llc_vector_cgrid
from .read_llc_fkij import read_llc_fkij
from .rect2llc import rect2llc
from .writebin import writebin
from .ts2dte import ts2dte
from .quikread import quikread
from .llc2rect import llc2rect
from .llc2rect import llc2rect_nd
from .quikpcolor import quikpcolor
from .readbin import readbin

__all__ = ['quikplot', 'plot', 'plot_llc_vector_cgrid', 'read_llc_fkij', 'rect2llc', 'writebin', 'ts2dte', 'quikread', 'llc2rect', 'llc2rect_nd','quikpcolor', 'readbin']
__version__ = "0.1.0"
