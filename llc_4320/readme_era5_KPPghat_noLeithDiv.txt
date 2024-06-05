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
# 120x120x10901 configuration
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_era5_KPPghat_noLeithDiv
module purge
module load comp-intel mpi-hpe
cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_120x120x10901 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_era5_KPPghat_noLeithDiv/mitgcmuv_120x120x10901

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv

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
mv data_noKPPbg_noLeithDiv data
mv data.kpp_Riinf_3.5 data.kpp
mv data.exf_era5 data.exf
mv data.seaice_noKPPbg data.seaice
mv data.exch2_120x120x10901 data.exch2
rm data.exch2_* data.exf_*
mpiexec -n 11904 ./mitgcmuv_120x120x10901

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv
tail -f STDOUT.00000 | grep advcfl_W

#############################
# 135x135x8697 configuration
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_test
module purge
module load comp-intel mpi-hpe
cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_135x135x8697 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_era5_KPPghat_noLeithDiv/mitgcmuv_135x135x8697

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv

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
mv data_noKPPbg_noLeithDiv data
mv data.kpp_Riinf_3.5 data.kpp
mv data.exf_era5 data.exf
mv data.seaice_noKPPbg data.seaice
mv data.exch2_135x135x8697 data.exch2
rm data.exch2_* data.exf_*
mpiexec -n 10752 ./mitgcmuv_135x135x8697

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv
tail -f STDOUT.00000 | grep advcfl_W

#############################
# 180x180x5015 configuration
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_era5_KPPghat_noLeithDiv
module purge
module load comp-intel mpi-hpe
cd ~/llc_4320/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_180x180x5015 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_era5_KPPghat_noLeithDiv/mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv

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
mv data_noKPPbg_noLeithDiv data
mv data.kpp_Riinf_3.5 data.kpp
mv data.exf_era5 data.exf
mv data.seaice_noKPPbg data.seaice
mv data.exch2_180x180x5015 data.exch2
rm data.exch2_* data.exf_*
mpiexec -n 6400 ./mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_era5_KPPghat_noLeithDiv
tail -f STDOUT.00000 | grep advcfl_W
