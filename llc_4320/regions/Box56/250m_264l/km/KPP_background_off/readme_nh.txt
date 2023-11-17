This directory contains configuration details for non-hydrostatic regional
simulations driven by llc4320 lateral boundary conditions.

To build and run on SciNet/Niagara, enter the following commands in the build
folder of the project:

module load NiaEnv/2019b
module load intel/2019u4
module load openmpi
module load hdf5/1.8.21
module load netcdf/4.6.3
cp ../code/CPP_OPTIONS.h_nh CPP_OPTIONS.h
../../../tools/genmake2 -mods=../code -mpi -of=../code/linux_amd64_ifort+mpi_niagara
make depend
make
cd ../run/
cp ../input/* .
mv data_nh data
cp ../build/mitgcmuv .
cd ..
sbatch OpenMPIjob
