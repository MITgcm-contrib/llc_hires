# This is a small test case with set-up as similar as possible
# to llc_4320 for testing asyncio and coupling to GEOS-5.

# request interactive nodes
qsub -I -q long -l select=6:ncpus=28:model=bro,walltime=120:00:00

#################################################
# 30x30x96 configuration no asyncio checkpoint65v
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
cd ~/geos5/asyncio
cvs co -r checkpoint65v MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_90
cd MITgcm
mkdir build run1
cd build
rm *
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_90/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_90/code
make depend
make -j 96
cp mitgcmuv ../run1
cd ../run1
ln -sf /nobackup/dmenemen/GEOS5/experiments/llc90/data/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input/* .
mpiexec -n 96 ./mitgcmuv

###################################################
# 30x30x96 configuration with asyncio checkpoint65v
cd ~/geos5/asyncio/MITgcm
mkdir run2
cd build
rm *
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_90/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_90/code ../../MITgcm_contrib/llc_hires/llc_90/code-async'
make depend
make -j 96
cp mitgcmuv ../run2
cd ../run2
ln -sf /nobackup/dmenemen/GEOS5/experiments/llc90/data/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input/* .
mpiexec -n 124 ./mitgcmuv

############################################
# 30x30x96 configuration with asyncio latest
cd ~/geos5/asyncio/MITgcm
mkdir run2
cd build
rm *
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_90/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_90/code ../../MITgcm_contrib/llc_hires/llc_90/code-async'
make depend
make -j 96
cp mitgcmuv ../run2
cd ../run2
ln -sf /nobackup/dmenemen/GEOS5/experiments/llc90/data/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input/* .
mpiexec -n 124 ./mitgcmuv
