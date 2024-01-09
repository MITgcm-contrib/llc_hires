C $Header: /u/gcmpack/MITgcm_contrib/gael/verification/global_oce_llc90/code/MOM_COMMON_OPTIONS.h,v 1.1 2012/10/03 20:27:37 gforget Exp $
C $Name:  $

C CPP options file for mom_common package
C Use this file for selecting CPP options within the mom_common package

#ifndef MOM_COMMON_OPTIONS_H
#define MOM_COMMON_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_MOM_COMMON
C     Package-specific options go here

C allow full 3D specification of horizontal Laplacian Viscosity
#define ALLOW_3D_VISCAH

C allow full 3D specification of horizontal Biharmonic Viscosity
#define ALLOW_3D_VISCA4

#endif /* ALLOW_MOM_COMMON */
#endif /* MOM_COMMON_OPTIONS_H */
