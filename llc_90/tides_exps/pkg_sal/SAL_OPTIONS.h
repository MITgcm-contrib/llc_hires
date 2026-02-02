C CPP options file for SAL

#ifndef SAL_OPTIONS_H
#define SAL_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_SAL
C Place CPP define/undef flag here

C just interpolate to lat-lon and back for debugging
#undef SAL_SKIP_GRID_CALCS

#endif /* ALLOW_SAL */
#endif /* SAL_OPTIONS_H */
