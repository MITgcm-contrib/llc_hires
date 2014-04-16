C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_270/code_ad/ECCO_CPPOPTIONS.h,v 1.1 2014/04/16 23:00:56 zhc Exp $
C $Name:  $

#ifndef ECCO_CPPOPTIONS_H
#define ECCO_CPPOPTIONS_H
#include "AD_CONFIG.h"
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_ECCO

C CPP flags controlling which code is included in the files that
C will be compiled.
C
C ********************************************************************
C ***                         ECCO Package                         ***
C ********************************************************************
C
C       >>> Do a long protocol.
#undef ECCO_VERBOSE
C       >>> use model/src/forward_step.F
#define ALLOW_ECCO_EVOLUTION

C ********************************************************************
C ***                  Adjoint Support Package                     ***
C ********************************************************************

#define ALLOW_AUTODIFF_TAMC
C
C       >>> Checkpointing as handled by TAMC
#define ALLOW_TAMC_CHECKPOINTING
# undef AUTODIFF_2_LEVEL_CHECKPOINT
C
C       >>> Extract adjoint state
#define ALLOW_AUTODIFF_MONITOR
C
C o use divided adjoint to split adjoint computations
#undef ALLOW_DIVIDED_ADJOINT
#undef ALLOW_DIVIDED_ADJOINT_MPI

#define ALLOW_AUTODIFF_WHTAPEIO
#define ALLOW_PACKUNPACK_METHOD2
#define AUTODIFF_USE_OLDSTORE_2D
#define AUTODIFF_USE_OLDSTORE_3D
#define EXCLUDE_WHIO_GLOBUFF_2D
#define ALLOW_INIT_WHTAPEIO

C ********************************************************************
C ***                     Calender Package                         ***
C ********************************************************************
C 
C CPP flags controlling which code is included in the files that
C will be compiled.

CPH >>>>>> THERE ARE NO MORE CAL OPTIONS TO BE SET <<<<<<

C ********************************************************************
C ***                Cost function Package                         ***
c ********************************************************************
C 
#define ALLOW_COST_FULL

#ifdef ALLOW_COST_FULL

C       >>> Cost function contributions
#define ALLOW_ECCO_OLD_FC_PRINT

C       >>> Initial values.
#define ALLOW_THETA0_COST_CONTRIBUTION
#define ALLOW_SALT0_COST_CONTRIBUTION
c so that the uncertainty fieldss are read in regardless:
#define ALLOW_WTHETALEV
#define ALLOW_WSALTLEV

C       >>> Surface fluxes.
# undef ALLOW_HFLUX_COST_CONTRIBUTION
# undef ALLOW_SFLUX_COST_CONTRIBUTION
# undef ALLOW_USTRESS_COST_CONTRIBUTION
# undef ALLOW_VSTRESS_COST_CONTRIBUTION

C       >>> Atmospheric state and radiation.
#define ALLOW_ATEMP_COST_CONTRIBUTION
#define ALLOW_AQH_COST_CONTRIBUTION
#define ALLOW_UWIND_COST_CONTRIBUTION
#define ALLOW_VWIND_COST_CONTRIBUTION
#define ALLOW_PRECIP_COST_CONTRIBUTION
# undef ALLOW_SWFLUX_COST_CONTRIBUTION
#define ALLOW_SWDOWN_COST_CONTRIBUTION
# undef ALLOW_LWFLUX_COST_CONTRIBUTION
#define ALLOW_LWDOWN_COST_CONTRIBUTION

C       >>> Ocean Parameters.
# undef ALLOW_EDDYPSI_COST_CONTRIBUTION
#define ALLOW_DIFFKR_COST_CONTRIBUTION
#define ALLOW_KAPGM_COST_CONTRIBUTION
# undef ALLOW_BOTTOMDRAG_COST_CONTRIBUTION
#define ALLOW_KAPREDI_COST_CONTRIBUTION

C       >>> Ocean Hydro. Atlas.
# undef GENERIC_BAR_MONTH
#define ALLOW_THETA_COST_CONTRIBUTION
#define ALLOW_SALT_COST_CONTRIBUTION

C       >>> ALLOW_GENCOST_CONTRIBUTION: interactive way to add basic 2D cost function terms.
C       > In data.ecco, this requires the specification of data file (name, frequency,
C         etc.), bar file name for corresp. model average, standard error file name, etc.
C       > In addition, adding such cost terms requires editing ecco_cost.h to increase
C         NGENCOST, and editing cost_gencost_customize.F to implement the actual
C         model average (i.e. the bar file content).
#define ALLOW_GENCOST_CONTRIBUTION
C       >>> free form version of GENCOST: allows one to use otherwise defined elements (e.g.
C         psbar and and topex data) while taking advantage of the cost function/namelist slots
C         that can be made available using ALLOW_GENCOST_CONTRIBUTION. To this end
C         ALLOW_GENCOST_CONTRIBUTION simply switches off tests that check whether all of the
C         gencost elements (e.g. gencost_barfile and gencost_datafile) are specified in data.ecco.
C       > While this option increases flexibility within the gencost framework, it implies more room
C         for error, so it should be used cautiously, and with good knowledge of the rest of pkg/ecco.
C       > It requires providing a specific cost function routine, and editing cost_gencost_all.F accordingly.
#define ALLOW_GENCOST_FREEFORM

#define COST_GENERIC_ASSUME_CYCLIC

#define ALLOW_GENCOST_SSHV4
#define ALLOW_GENCOST_SSHV4_OUTPUT
#define ALLOW_SHALLOW_ALTIMETRY
#define ALLOW_HIGHLAT_ALTIMETRY
#define ALLOW_PSBAR_MEAN
#define ALLOW_PSBAR_STERIC
# undef ALLOW_PSBAR_GENPRECIP
# undef ALLOW_GENTIM2D_CONTROL

# undef ALLOW_GENCOST_SSTV4
# undef ALLOW_GENCOST_SSTV4_OUTPUT

#define ALLOW_SEAICE_COST_CONTRIBUTION
#define ALLOW_GENCOST_SEAICEV4

C       >>> User Cost Function Terms.
#define ALLOW_USERCOST_CONTRIBUTION
# undef ALLOW_USERCOST_TSUV_CONTRIBUTION
# undef ALLOW_USERCOST_TSdrift_CONTRIBUTION

C       >>> In-Situ Profiles.
#define ALLOW_PROFILES_CONTRIBUTION

C       >>> GRACE Bottom Pressure.
#define ALLOW_BP_COST_CONTRIBUTION
#define ALLOW_BP_COST_OUTPUT

C       >>> Surface Observations.
# undef ALLOW_DRIFTER_COST_CONTRIBUTION
#define ALLOW_SST_COST_CONTRIBUTION
#define ALLOW_TMI_SST_COST_CONTRIBUTION
#define ALLOW_DAILYSST_COST_CONTRIBUTION
# undef ALLOW_SSS_COST_CONTRIBUTION
# undef ALLOW_SEAICE_COST_SMR_AREA
#define ALLOW_DAILYSCAT_COST_CONTRIBUTION

C       >>> Sea Surface Height Observation/Estimates.
#define ALLOW_EGM96_ERROR_DIAG
#define ALLOW_SSH_MEAN_COST_CONTRIBUTION
#define ALLOW_SSH_TPANOM_COST_CONTRIBUTION
#define ALLOW_SSH_ERSANOM_COST_CONTRIBUTION
#define ALLOW_SSH_GFOANOM_COST_CONTRIBUTION
# if (defined (ALLOW_SSH_MEAN_COST_CONTRIBUTION) || \
      defined (ALLOW_SSH_TPANOM_COST_CONTRIBUTION) || \
      defined (ALLOW_SSH_ERSANOM_COST_CONTRIBUTION))
#  define ALLOW_SSH_COST_CONTRIBUTION
# endif
# undef ALLOW_NEW_SSH_COST
#define ALLOW_SSH_TOT
# ifndef ALLOW_EGM96_ERROR_DIAG
#  undef ALLOW_SSH_TOT
# endif

c
#endif /* ALLOW_COST_FULL */


C ********************************************************************
C ***               Control vector Package                         ***
C ********************************************************************
C 
#define EXCLUDE_CTRL_PACK
# undef  CTRL_SET_OLD_MAXCVARS_30
#define  CTRL_SET_PREC_32
# undef  ALLOW_NONDIMENSIONAL_CONTROL_IO
# undef  CTRL_UNPACK_PRECISE
# undef  CTRL_PACK_PRECISE

C       >>> Spatial Correlation Operator.
#define ALLOW_SMOOTH_CORREL3D
#define ALLOW_SMOOTH3D
#define ALLOW_SMOOTH_CORREL2D
#define ALLOW_SMOOTH2D
#define ALLOW_ADCTRLBOUND

C       >>> Initial values.
#define ALLOW_THETA0_CONTROL
#define ALLOW_SALT0_CONTROL

C       >>> Surface fluxes.
# undef ALLOW_HFLUX_CONTROL
# undef ALLOW_SFLUX_CONTROL
# undef ALLOW_USTRESS_CONTROL
# undef ALLOW_VSTRESS_CONTROL

C       >>> Atmospheric state and radiation.
#define  ALLOW_ATEMP_CONTROL
#define  ALLOW_AQH_CONTROL
#define  ALLOW_UWIND_CONTROL
#define  ALLOW_VWIND_CONTROL
#define  ALLOW_PRECIP_CONTROL
# undef  ALLOW_SWFLUX_CONTROL
#define  ALLOW_SWDOWN_CONTROL
# undef  ALLOW_LWFLUX_CONTROL
#define  ALLOW_LWDOWN_CONTROL

C       >>> Ocean Parameters.
# undef ALLOW_EDDYPSI_CONTROL
#define ALLOW_DIFFKR_CONTROL
#define ALLOW_KAPGM_CONTROL
# undef ALLOW_BOTTOMDRAG_CONTROL
#define ALLOW_KAPREDI_CONTROL

C       >>> rotation of xx for wind
#define ALLOW_ROTATE_UV_CONTROLS



C   Specific relaxation strategy
# undef ALLOW_RBCS_SPIN

#endif /* ALLOW_ECCO */
#endif /* ECCO_CPPOPTIONS_H */

