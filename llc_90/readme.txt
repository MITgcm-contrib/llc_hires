# This is a small test case with set-up as similar as possible
# to llc_4320 for testing asyncio and coupling to GEOS-5.

# Get MITgcm from GitHub
#- method 1, using https:
 git clone https://github.com/MITgcm/MITgcm.git
#- method 2, using ssh (requires a github account):
 git clone git@github.com:MITgcm/MITgcm.git

# Get MITgcm_contrib from CVS
cvs co MITgcm_contrib/llc_hires/llc_90

# request interactive nodes and load modules
qsub -I -q long -l select=5:ncpus=28:model=bro,walltime=120:00:00
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt

########################################
# 30x30x96 configuration without asyncio
cd MITgcm
mkdir build run1
cd build
rm *
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_90/code
make depend
make -j 96
cd ../run1
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_90/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input/* .
mpiexec -n 96 ./mitgcmuv

#####################################
# 30x30x96 configuration with asyncio
cd ../../MITgcm
mkdir run2
cd build
rm *
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_90/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_90/code-async ../../MITgcm_contrib/llc_hires/llc_90/code'
make depend
make -j 96
cd ../run2
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_90/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input/* .
mv data_async data
mpiexec -n 136 ./mitgcmuv

###################################################
# 30x30x96 configuration with asyncio and no seaice
# Hangs after first "I/O ranks waiting for new epoch"
cd ../../MITgcm
mkdir run4
cd build
rm *
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_90/code-async/linux_amd64_ifort+mpi_ice_nas \
  -mpi -mods ../../MITgcm_contrib/llc_hires/llc_90/code-async-noseaice
make depend
make -j 16
cd ../run4
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_90/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackupp2/dmenemen//llc_4320/run_template/runoff1p2472-360x180x12.bin .
cp ../../MITgcm_contrib/llc_hires/llc_90/input-noseaice/* .
mpiexec -n 124 ./mitgcmuv
