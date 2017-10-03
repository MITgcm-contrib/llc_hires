# This is a small test case with set-up as similar as possible
# to llc_4320 for testing asyncio and coupling to GEOS-5.

#############################
# 30x30x96 configuration

module purge
module load comp-intel/2015.0.090 mpi-sgi/mpt.2.12r23 netcdf/4.0
cd ~/llc_4320
cvs co -r checkpoint65v MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build run485568
lfs setstripe -c -1 run_485568
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_90x90x19023 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 90;
    tileSizeY = 90;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cp mitgcmuv ../run_485568/mitgcmuv_90x90x19023_intel.2015.0.090

qsub -I -q long -l select=850:ncpus=24:model=has,walltime=120:00:00 -m abe -M menemenlis@me.com
qsub -I -q long -l select=1020:ncpus=20:model=ivy,walltime=120:00:00 -m abe -M menemenlis@me.com
module load comp-intel/2015.0.090 mpi-sgi/mpt.2.12r23 netcdf/4.0
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
cp data.exch2_90x90x19023 data.exch2
mv STDOUT.00000 STDOUT.485568
emacs data
 nIter0=485568,
ln -sf ../run/pickup_0000485568.data pickup.0000485568.data
ln -sf ../run/pickup_0000485568.meta pickup.0000485568.meta
ln -sf ../run/pickup_seaice_0000485568.data pickup_seaice.0000485568.data
ln -sf ../run/pickup_seaice_0000485568.meta pickup_seaice.0000485568.meta
mpiexec -n 20400 ./mitgcmuv_90x90x19023_intel.2015.0.090

cd ~/llc_4320/MITgcm/run_485568
tail -f STDOUT.00000 | grep advcfl_W

