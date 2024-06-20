from 68g
grep advcfl_W_hf_max STDOUT.0000_checkpoint68g
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7652375388444E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.6774901863126E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.2485109946982E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5729702310040E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.4725944528547E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.5627259547965E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0734092025490E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3293011515173E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1005537356872E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1770199660306E-01

to 68h (same as 68g)

to 68i
changing "ini_parms.F" using 68h but keep bloc of
#ifdef ALLOW_SHELFICE
#include "SHELFICE_OPTIONS.h"
#endif
#ifndef shelfice_new_thermo
...
#else
...
#endif
grep advcfl_W_hf_max STDOUT.0000_checkpoint68i
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7652375388459E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.6774901897621E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.2485110038847E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5729702265894E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.4725944517721E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.5627259119122E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0734092032952E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3293011509197E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1005537400947E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1770199613584E-01

to 68j (same as 68i)
o pkg/shelfice:
  - Remove ALLOW_SHIFWFLX_CONTROL and all xx_shifwflx related code in favor of
    already implemented gentim2d;
  - move update of shelficeLoadAnomaly inside shelfice_step_icemass.F (within
    IF (SHELFICEMassStepping) ...);
  - fix storage dir for SHELFICEMassStepping, allowing to realFreshWaterFlux=T
    with ALLOW_AUTODIFF defined (remove STOP there). Still not working with
    OpenAD (add a STOP in shelfice_check.F).

to 68k (same as 68j)
o pkg/gmredi:
  - allow to read-in 3-D background isopycnal (Redi) and thickness (GM)
    diffusivity without pkg/ctrl: new 3-D arrays, new CPP options:
    GM_READ_K3D_REDI & GM_READ_K3D_GM and new input files: GM_K3dRediFile &
    GM_K3dGMFile (replacing retired GM_isopycK3dFile & GM_background_K3dFile).
  - update code for ALLOW_KAPGM_CONTROL & ALLOW_KAPREDI_CONTROL to use
    these new 3-D arrays (from GMREDI.h) and move setting of 3-D control arrays
    from from ini_mixing.F to gmredi_init_varia.F (+ adjust call condition);
deleting "mixing" files:
CTRL_FIELDS.h
gmredi_calc_psi_b.F
gmredi_calc_tensor.F
ini_mixing.F
changing "GMREDI_OPTIONS.h" + associated "data.gmredi"

to 68l
grep advcfl_W_hf_max STDOUT.0000_checkpoint68l
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7652374747046E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.6774901755727E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.2485181476416E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5730006035399E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.4725020752047E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.5627352003055E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0733947705240E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3292819600595E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1005924598385E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1770740722554E-01

to 68m
o pkg/gmredi:
  - update Redi diffusion and GM (skew-flux or advective form) to also work with
    P-coordinates and most current tapering schemes ; change sign of sigmaR (for
    now, only within pkg/gmredi) to always be the same as stratification, i.e.,
    positive if stratified ; add 2 arguments to GMREDI_SLOPE_LIMIT for 'ldd97'.
  - with p-coord, keep sign of slope component unchanged (same as dSigmaX,Y)
    and flip sign (-gravitySign) of Redi-tensor extra-diagonal terms ; also keep
    stream-function components GM_PsiX & GM_PsiY unchanged and flip sign when
    computing bolus-transport (left handed coord).
  - add unit conversion factor between p and z coord. at level center, function
    of vertical profile of ref. density ; used inside slope-limiter and tapering function.
  - stop if trying to use P-coord with not yet updated gmredi pieces of code.
  - add a simple secondary test in front_relax exp. using GM and p-coord.
grep advcfl_W_hf_max STDOUT.0000_checkpoint68m
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7652374747096E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.6774901754248E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.2485180971304E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5730006038021E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.4725020760465E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.5627351873612E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0733947707291E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3292819604165E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1005924613352E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1770740807377E-01

to 68n (same as 68m)

to 68o (same as 68n)


comparison between c68g and c68o shown by c68g_c68o_eta.png

to 68p
disable bloc for SIaaflux @data.diagnostic
same as 68o

to 68q
same as 68p

to 68r
SWFRACB ==> SEAICE_SWFrac @seaice_growth_adx.F
same as 68q

to 68s
same as 68r

to 68t
same as 68s

to 68u
same as 68t

to 68v
ini_parms.F ==> as model/src/ but keep shelice part
SHELFICE.h  ==> add "SHI_update_kTopC"
same as 68u

to 68w
same as 68v

to 68x
same as 68w

to 68y
same as 68x
