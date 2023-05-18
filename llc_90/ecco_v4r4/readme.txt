This repo is based on
https://github.com/MITgcm-contrib/ecco_darwin/tree/master/v05/1deg/code_v4r4

Uneeded files have been removed and MITgcm has been stepped forward from
checkpoint_66g to checkpoint_68o while maintaining 8-digit accuracy for
advcfl_W_hf_max after a 10-day integration.

darwin_v4r4 is identical to ecco_v4r4_66g to ecco_v4r4_67k

#changes needed due to pkg/seaice changes
#from checkpoint67c to checkpoint67d
      SEAICEscaleSurfStress=.FALSE.,
      SEAICEaddSnowMass=.FALSE.,
      SEAICE_OLx=0,
      SEAICE_OLy=0,
      SEAICEetaZmethod=0,
      SEAICE_waterDrag=5.34499514091350826D-3,

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_67k/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467098E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949749E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181572736E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107771825E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318458341E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615388383E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808731036766E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535429554E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132759029E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001970457E-01

checkpoint67l (2019/08/29)
o pkg/mom_common & model/src:
  - new S/R MOM_U/V_BOTDRAG_COEF used both for explicit and implicit bottom drag
    computation (thus replacing both MOM_U/V_BOTTOMDRAG in explicit case and
    MOM_U/V_BOTDRAG_IMPL in implicit case) to return a drag coefficient.
    This modification affects results at machine truncation level.

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_67l/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467086E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949746E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181531878E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107772211E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318719359E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615497554E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808734686405E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535423817E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132758001E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001977669E-01

checkpoint67r (2020/06/04)
o model/src & pkg/exf:
  - Reference atmospheric pressure for seawater EOS was assumed but was not
    explicitly set. New constant "eosRefP0" is added to make this more clear ;
  - Add main model reference surface pressure (surf_pRef) so that pLoad
    is now defined as the atmospheric pressure anomaly relative to surf_pRef ;
  - Account for differences in 2 ref pressure in EOS S/R ;
  - Fix few EOS references (in comments) ; fix and simplify S/R EOS_CHECK ;
  - Keep exf "apressure" field unchanged (still full atmospheric surface
    pressure) but now initialised to "surf_pRef" and fill "pLoad" with atmos.
    pressure anomaly relative to surf_pRef.

The following change in exf_mapfields.F affects results at machine truncation level:
321d320
< C-    subtract "surf_pRef" to fill in atmos. pressure anomaly "pLoad"
324,325c323
<              pLoad(i,j,bi,bj) =
<      &          exf_outscal_apressure*apressure(i,j,bi,bj) - surf_pRef
---
>              pLoad(i,j,bi,bj)=exf_outscal_apressure*apressure(i,j,bi,bj)

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_67r/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467120E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949749E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181514012E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107772076E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318698266E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615568191E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808735106587E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535429253E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132761151E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001985343E-01

checkpoint67u (2020/12/30)
o pkg/seaice:
 - fix bug in seaice_lsr, spotted by Martin Vancoppenolle, that lead to solving
   stationary momentum equations (du/dt -> 0) for SEAICEnonLinIterMax>2 ;
 - fix minor bug in seaice_bottomdrag_coeffs.F: replace OLy with correct OLx ;
 - changing ordering of addition (to FORCEX,FORCEY) in seaice_lsr.F results in
   output differences at machine truncation level: update referece output of
   several experiments that use LSR solver.

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_67u/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467036E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949745E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181550317E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107772047E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318729797E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615515374E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808734578317E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535426596E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132753084E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001981025E-01

checkpoint68b (2021/08/24)
o model/src + pkgs ggl90, exf & seaice: ocean in P-coordinate
  - add a flag sIceLoadFac (in "data", default=1.) to be able to turn off
    seaice surface pressure loading, mainly for Z-coord (since not currently
    supported in P-coord) ;

The following change in external_forcing_surf.F affects results at machine truncation level:
364c364
<      &                          +sIceLoad(i,j,bi,bj)*gravity*sIceLoadFac
---
>      &                          +sIceLoad(i,j,bi,bj)*gravity

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_68b/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467098E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949746E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181538742E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107772098E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318729285E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615505913E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808734821289E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535419618E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132761129E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001982561E-01

checkpoint68i (2022/04/27)
o pkg/gmredi:
  - add deep-factor to pkg/gmredi code to work with "deepAtmosphere=T".

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_68i/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467052E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949747E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181507173E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107771691E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318670535E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615546702E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808734770459E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535424598E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132759284E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001976787E-01

checkpoint68i is identical to checkpoint68l

checkpoint68k (2022/08/17)
o pkg/gmredi:
  - allow to read-in 3-D background isopycnal (Redi) and thickness (GM)
    diffusivity without pkg/ctrl: new 3-D arrays, new CPP options:
    GM_READ_K3D_REDI & GM_READ_K3D_GM and new input files: GM_K3dRediFile &
    GM_K3dGMFile (replacing retired GM_isopycK3dFile & GM_background_K3dFile).

Changes needed for going from checkpoint68j to checkpoint68k:

delete following files from code:
CTRL_FIELDS.h
gmredi_calc_psi_b.F
gmredi_calc_tensor.F
ini_mixing.F

diff -r code_v4r4/GMREDI_OPTIONS.h ../ecco_v4r4_68j/code_v4r4/GMREDI_OPTIONS.h
11a12,19
> C initialize KapGM and KapRedi from a file
> chzh[
> #define ALLOW_KAPGM_CONTROL
> #define ALLOW_KAPREDI_CONTROL
> chzh]
> #define ALLOW_KAPGM_3DFILE
> #define ALLOW_KAPREDI_3DFILE
> 
20,24d27
< 
< C Allows to read-in background 3-D Redi and GM diffusivity coefficients
< C Note: need these to be defined for use as control (pkg/ctrl) parameters
< #define GM_READ_K3D_REDI
< #define GM_READ_K3D_GM

diff -r input_v4r4/data.gmredi ../ecco_v4r4_68j/input_v4r4/data.gmredi
28,29c28,29
<   GM_K3dGMFile       = 'eccov4_r4_kapgm.data',
<   GM_K3dRediFile     = 'eccov4_r4_kapredi.data',
---
>   GM_background_K3dFile='eccov4_r4_kapgm.data',
>   GM_isopycK3dFile='eccov4_r4_kapredi.data',

checkpoint68m is identical to checkpoint68o

checkpoint68m (2022/12/05)
o pkg/gmredi:
  - update Redi diffusion and GM (skew-flux or advective form) to also work with
    P-coordinates and most current tapering schemes ; change sign of sigmaR (for
    now, only within pkg/gmredi) to always be the same as stratification, i.e.,
    positive if stratified ; add 2 arguments to GMREDI_SLOPE_LIMIT for 'ldd97'.
  - with p-coord, keep sign of slope component unchanged (same as dSigmaX,Y)
    and flip sign (-gravitySign) of Redi-tensor extra-diagonal terms ; also keep
    stream-function components GM_PsiX & GM_PsiY unchanged and flip sign when
    computing bolus-transport (left handed coord).
  - add unit conversion factor between p and z coord. at level center, function of
    vertical profile of ref. density ; used inside slope-limiter and tapering function.
  - stop if trying to use P-coord with not yet updated gmredi pieces of code.
  - add a simple secondary test in front_relax exp. using GM and p-coord.

bash-4.2$ pwd
/nobackup/dmenemen/Jason/ecco_v4r4_68m/MITgcm/run
bash-4.2$ grep advcfl_W STDOUT.0000 | head 
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7771644467056E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5523745949748E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3434181535317E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5001107772084E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3330318738588E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3856615510777E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9808734796628E-02
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.1562535418491E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8154132763620E-01
(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.1529001980648E-01

comparison between c66g and c68o shown by c66g_c68o_eta.png
