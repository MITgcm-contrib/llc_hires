#############################
# 72x72x29297 configuration

cd /nobackupp11/dmenemen/llc_4320/MITgcm/run_notides
ls -l pickup_0*data
mv STDOUT.00000 STDOUT.513216
emacs data
 nIter0=513216,
ln -sf pickup_0000513216.data pickup.0000513216.data
ln -sf pickup_0000513216.meta pickup.0000513216.meta
ln -sf pickup_seaice_0000513216.data pickup_seaice.0000513216.data
ln -sf pickup_seaice_0000513216.meta pickup_seaice.0000513216.meta
qsub qsub_llc4320_32000

qstat alphatst
tail -f STDOUT.00000 | grep advcfl_W


#############################
# 60x60x41851 configuration

module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
cd /nobackupp11/dmenemen/llc_4320
cvs co -r checkpoint65v MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_60x60x41851 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 60;
    tileSizeY = 60;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
mv mitgcmuv mitgcmuv_60x60x41851
cp mitgcmuv_60x60x41851 ../run_notides
