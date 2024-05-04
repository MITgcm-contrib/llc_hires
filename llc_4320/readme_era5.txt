# llc4320 with:
# - latest (checkpoint68t) MITgcm
# - ERA5 forcing
# - no KPP background diffusivity and viscosity
# - Leithd = 0
# - Joe Skitka's Leith modifications
# - Bron's latest asyncio code
# - Oliver's pkg/tides
#   https://github.com/jahn/MITgcm/tree/tides
#   https://github.com/jahn/ECCO-v4-Configurations/tree/tides/ECCOv4%20Release%204/tides

#############################
# 180x180x5015 configuration using github and comp-intel/2020.4.304
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_era5
module purge
module load comp-intel/2020.4.304 mpi-hpe/mpt
cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_180x180x5015 SIZE.h
cp ../../llc_hires/llc_4320/code/mom_vi_del2uv.F_jms mom_vi_del2uv.F
cp ../../llc_hires/llc_4320/code/mom_vi_hdissip.F_jms mom_vi_hdissip.F
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_era5/mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_era5

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
cp ../../llc_hires/llc_4320/input/* .
mv data_noKPPbg data
mv data.exf_era5 data.exf
mv data.seaice_noKPPbg data.seaice
mv data.exch2_180x180x5015 data.exch2
rm data.exch2_* data.exf_*
mpiexec -n 5360 ./mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_era5
tail -f STDOUT.00000 | grep advcfl_W

#############################
# instability crash on time step 623030
# restart from 622944 adding some background KPP diffusivity
emacs data
 viscAr= 5.e-5,
 diffKrT=5.e-6,
 diffKrS=5.e-6,
 nIter0=622944,
 hydrogThetaFile='Theta.0000622944.data',
 hydrogSaltFile ='Salt.0000622944.data',
 uVelInitFile   ='U.0000622944.data',
 vVelInitFile   ='V.0000622944.data',
 pSurfInitFile  ='Eta.0000622944.data',
emacs data.seaice
      AreaFile           = 'SIarea.0000622944.data',
      HsnowFile          = 'SIhsnow.0000622944.data',
      HsaltFile          = 'SIhsalt.0000622944.data',
      HeffFile           = 'SIheff.0000622944.data',
      UiceFile           = 'SIuice.0000622944.data',
      ViceFile           = 'SIvice.0000622944.data',
mv STDOUT.00000 STDOUT.0000622944
mpiexec -n 5360 ./mitgcmuv_180x180x5015
