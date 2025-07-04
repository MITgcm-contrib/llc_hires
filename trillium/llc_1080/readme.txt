cd ~/llc1080
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
git checkout checkpoint69e
mkdir build run
module purge
module load comp-intel mpi-hpe



cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/v02/code-async/SIZE.h_135x135x8697 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/v02/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/v02/code ../../llc_hires/llc_4320/v02/code-async'
make depend
make -j
cp mitgcmuv ../run_v02/mitgcmuv_135x135x8697




- run with new llc1080 bathymetry no initial conditions
- add ice shelves
- add initial conditions






# llc4320 version 2 (v02)

~dmenemen/llc_4320/MITgcm/run_v02a
CPP_OPTIONS.h
#define SOLVE_DIAGONAL_LOWMEMORY

~dmenemen/llc_4320/MITgcm/run_v02
CPP_OPTIONS.h
#define EXCLUDE_PCELL_MIX_CODE
#define ALLOW_SOLVE4_PS_AND_DRAG
data
 &PARM01
 viscAr= 1e-6,  (the molecular viscosity value)
 no_slip_sides = .FALSE.,
 selectImplicitDrag = 2,
 selectP_inEOS_Zc = 1,
 &PARM04
 pCellMix_select = 2,
 pCellMix_viscAr = 90*4.e-4,
 pCellMix_diffKr = 90*2.e-4,

>>>>>>>


aiming for:
z*
ggl90
implicit bottom drag

data
 hFacMin=0.1,
 hFacInf=0.05,
 hFacSup=5.,
 highOrderVorticity  = .FALSE.,
 selectVortScheme = 2
 selectCoriScheme = 1
 selectBotDragQuadr = 1
# multiDimAdvection=.TRUE.,
# implicitFreeSurface=.TRUE.,
# convertFW2Salt=-1.,
 select_rStar=2,
 nonlinFreeSurf=4,
 cg2dTargetResidual = 1.E-6,

email martin about data.ggl90 and about sea ice dynamics that magically avoids
to have too thick ice




# llc4320 with:
# - latest (checkpoint68x) MITgcm
# - ERA5 forcing
# - no KPP background diffusivity and viscosity
# - Leithd = 0
# - Joe Skitka's Leith modifications with
#      viscC4leithDiv=0.0,
#      leithDivDmask=0.0,
#      leithDivFmask=500.,
# - Bron's latest asyncio code
# - Oliver's pkg/tides
#   https://github.com/jahn/MITgcm/tree/tides
#   https://github.com/jahn/ECCO-v4-Configurations/tree/tides/ECCOv4%20Release%204/tides
# - KPP includes GHAT, UREF, and a few more recent additions with "Riinfty=3.5"
# - use drag formulation of Large and Yeager (2009), Climate Dyn., 33, pp 341-364
#      "define ALLOW_DRAG_LARGEYEAGER09" in EXF_OPTIONS.h

#############################
# 135x135x8697 configuration
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_v02
module purge
module load comp-intel mpi-hpe
cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/v02/code-async/SIZE.h_135x135x8697 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/v02/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/v02/code ../../llc_hires/llc_4320/v02/code-async'
make depend
make -j
cp mitgcmuv ../run_v02/mitgcmuv_135x135x8697

cd ~/llc_4320/MITgcm/run_v02

# Extract March 1, 2012 initial conditions
# ts = dte2ts('01-Mar-2012',25,2011,9,10)
# ts = 597888
#~/llc_4320/extract/uncompress4320 597888 Eta,Salt,Theta,U,V
#~/llc_4320/extract/uncompress4320 597888 SIarea,SIheff,SIhsalt,SIhsnow,SIuice,SIvice

ln -sf ../run_noKPPbg_newLeith/0000597888* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/bathy4320_g5_r4 .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/tile* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp ../../llc_hires/llc_4320/v02/input/* .
mv data.exch2_135x135x8697 data.exch2
mpiexec -n 11008 ./mitgcmuv_135x135x8697

cd ~/llc_4320/MITgcm/run_v02
tail -f STDOUT.00000 | grep advcfl_W
