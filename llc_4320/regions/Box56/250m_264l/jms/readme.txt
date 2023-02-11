2/22/2023 - JOSEPH SKITKA - Joseph.Skitka@gmail.com

WARNING: do not attempt to use this code without understanding it first.
This is a very ugly / quick adapation to the following routines:
     mom_vi_hdissip.F
     mom_vi_del2uv.F
so that Leith (approximately) only acts on the horizontally rotational part of
the flow.

WARNING: this code will only work of mom_vi_hdissip.F and mom_vi_del2uv.F are
not used by any other part of the code.  Horizontal viscosity needs to be
computed using the vector invariant formulation.  Otherwise this will not
work!!

This directory contains configuration details for regional simulations driven
by llc4320 lateral boundary conditions.  To build and run on SciNet/Niagara,
enter the following commands in the build folder of the project:

module load NiaEnv/2019b
module load intel/2019u4
module load openmpi
module load hdf5/1.8.21
module load netcdf/4.6.3
../../../tools/genmake2 -mods=../code -mpi -of=../code/linux_amd64_ifort+mpi_niagara
make depend
make
cd ../run/
ln -s ../input/* .
cp ../build/mitgcmuv .
cd ..
sbatch OpenMPIjob
