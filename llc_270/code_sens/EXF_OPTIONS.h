C $Header: /u/gcmpack/MITgcm_contrib/gael/verification/global_oce_llc90/code/EXF_OPTIONS.h,v 1.2 2014/10/20 03:29:00 gforget Exp $
C $Name:  $

CBOP
C !ROUTINE: EXF_OPTIONS.h
C !INTERFACE:
C #include "EXF_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | CPP options file for EXternal Forcing (EXF) package:
C | Control which optional features to compile in this package code.
C *==================================================================*
CEOP

#ifndef EXF_OPTIONS_H
#define EXF_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_EXF
#ifdef ECCO_CPPOPTIONS_H

C-- When multi-package option-file ECCO_CPPOPTIONS.h is used (directly included
C    in CPP_OPTIONS.h), this option file is left empty since all options that
C   are specific to this package are assumed to be set in ECCO_CPPOPTIONS.h

#else /* ndef ECCO_CPPOPTIONS_H */

C-- Package-specific Options & Macros go here

c   pkg/exf CPP options:
c   --------------------
c
c   > ( EXF_VERBOSE ) < replaced with run-time, logical parameter "exf_verbose".
c
c   >>> ALLOW_ATM_WIND <<<
c       If defined, 10-m wind fields can be read-in from files.
c
c   >>> ALLOW_ATM_TEMP <<<
c       If defined, atmospheric temperature and specific
c       humidity fields can be read-in from files.
c
c   >>> ALLOW_DOWNWARD_RADIATION <<<
c       If defined, downward long-wave and short-wave radiation
c       can be read-in form files or computed from lwflux and swflux.
c
c   >>> ALLOW_ZENITHANGLE <<<
c       If defined, ocean albedo varies with the zenith angle, and
c       incoming fluxes at the top of the atmosphere are computed
c
c   >>> ALLOW_BULKFORMULAE <<<
c       Allows the use of bulk formulae in order to estimate
c       turbulent and radiative fluxes at the ocean surface.
c
c   >>> EXF_READ_EVAP <<<
c       If defined, evaporation fields are read-in, rather than
c       computed from atmospheric state.
c
c   >>> ALLOW_RUNOFF <<<
c       If defined, river and glacier runoff can be read-in from files.
c
c   >>> ATMOSPHERIC_LOADING <<<
c       If defined, atmospheric pressure can be read-in from files.
c   WARNING: this flag is set (define/undef) in CPP_OPTIONS.h
c            and cannot be changed here (in EXF_OPTIONS)
c
c   >>> ICE_AREAMASK <<<
c       If defined, fractional ice-covered area MASK can be read-in from files.
c
c   >>> ALLOW_CLIMSST_RELAXATION <<<
c       Allow the relaxation to a monthly climatology of sea surface
c       temperature, e.g. the Reynolds climatology.
c
c   >>> ALLOW_CLIMSSS_RELAXATION <<<
c       Allow the relaxation to a monthly climatology of sea surface
c       salinity, e.g. the Levitus climatology.
c
c   >>> USE_EXF_INTERPOLATION <<<
c       Allows specification of arbitrary Cartesian input grids.
c
c   ====================================================================
c
c       The following CPP options:
c
c          ALLOW_ATM_WIND              (WIND)
c          ALLOW_ATM_TEMP              (TEMP)
c          ALLOW_DOWNWARD_RADIATION    (DOWN)
c          ALLOW_BULKFORMULAE          (BULK)
c          EXF_READ_EVAP               (EVAP)
c
c       permit the ocean-model forcing configurations listed in the
c       table below.  The first configuration is the default,
c       flux-forced, ocean model.  The next four are stand-alone
c       configurations that use pkg/exf, open-water bulk formulae to
c       compute the missing surface fluxes from atmospheric variables.
c       The last four configurations can be used in conjunction with
c       pkg/seaice to model ice-covered regions.  The forcing fields
c       in the rightmost column are defined in exf_fields.
c
c
c    WIND |TEMP |DOWN |BULK |EVAP |            actions
c    -----|-----|-----|-----|-----|-------------------------------------
c         |     |     |     |     |
c      -  |  -  |  -  |  -  |  -  | Read-in ustress, vstress, hflux,
c         |     |     |     |     | swflux, and sflux.
c         |     |     |     |     |
c     def | def | def | def |  -  | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swdown, lwdown, precip, and runoff.
c         |     |     |     |     | Compute ustress, vstress, hflux,
c         |     |     |     |     | swflux, and sflux.
c         |     |     |     |     |
c     def | def |  -  | def |  -  | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swflux, lwflux, precip, and runoff.
c         |     |     |     |     | Compute ustress, vstress, hflux,
c         |     |     |     |     | and sflux.
c         |     |     |     |     |
c     def |  -  |  -  | def |  -  | Read-in uwind, vwind, hflux,
c         |     |     |     |     | swflux, and sflux.
c         |     |     |     |     | Compute ustress and vstress.
c         |     |     |     |     |
c      -  | def |  -  | def |  -  | Read-in ustress, vstress, atemp,
c         |     |     |     |     | aqh, swflux, lwflux, precip, and
c         |     |     |     |     | runoff.  Compute hflux and sflux.
c         |     |     |     |     |
c     def | def |  -  |  -  | def | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swflux, lwflux, precip, runoff,
c         |     |     |     |     | and evap.
c         |     |     |     |     |
c     def | def |  -  | def |  -  | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swflux, lwflux, precip, and runoff.
c         |     |     |     |     | Compute open-water ustress, vstress,
c         |     |     |     |     | hflux, swflux, and evap.
c         |     |     |     |     |
c     def | def | def |  -  | def | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swdown, lwdown, precip, runoff,
c         |     |     |     |     | and evap.
c         |     |     |     |     |
c     def | def | def | def |  -  | Read-in uwind, vwind, atemp, aqh,
c         |     |     |     |     | swdown, lwdown, precip, and runoff.
c         |     |     |     |     | Compute open-water ustress, vstress,
c         |     |     |     |     | hflux, swflux, and evap.
c
c   ====================================================================

C   Bulk formulae related flags.
#define  ALLOW_ATM_TEMP
#define  ALLOW_ATM_WIND
#define  ALLOW_DOWNWARD_RADIATION
#define  ALLOW_RUNOFF
#if (defined (ALLOW_ATM_TEMP) || defined (ALLOW_ATM_WIND))
# define ALLOW_BULKFORMULAE
# define ALLOW_BULK_LARGEYEAGER04
#endif

C   Zenith Angle/Albedo related flags.
#ifdef ALLOW_DOWNWARD_RADIATION
# define ALLOW_ZENITHANGLE
#  undef ALLOW_ZENITHANGLE_BOUNDSWDOWN
#endif

C   Use ocean_emissivity*lwdwon in lwFlux. This flag should be define
C   unless to reproduce old results (obtained with inconsistent old code)
#ifdef ALLOW_DOWNWARD_RADIATION
# define EXF_LWDOWN_WITH_EMISSIVITY
#endif

C   Relaxation to monthly climatologies.
#define ALLOW_CLIMSST_RELAXATION
#define ALLOW_CLIMSSS_RELAXATION

C   Use spatial interpolation to interpolate
C   forcing files from input grid to model grid.
#define USE_EXF_INTERPOLATION
C   for interpolated vector fields, rotate towards model-grid axis
C   using old rotation formulae (instead of grid-angles)
#undef EXF_USE_OLD_VEC_ROTATION
C   for interpolation around N & S pole, use the old formulation
C   (no pole symmetry, single vector-comp interp, reset to 0 zonal-comp @ N.pole)
#undef EXF_USE_OLD_INTERP_POLE

#define EXF_INTERP_USE_DYNALLOC
#if ( defined (EXF_INTERP_USE_DYNALLOC) && defined (USING_THREADS) )
# define EXF_IREAD_USE_GLOBAL_POINTER
#endif

#endif /* ndef ECCO_CPPOPTIONS_H */
#endif /* ALLOW_EXF */
#endif /* EXF_OPTIONS_H */
