1/13/2024 - JOSEPH SKITKA - Joseph.Skitka@gmail.com

to be used with MITgcm source code, publicly available at http://mitgcm.org/public/source_code.html

The following files have been adapted:
     PARAMS.h
     config_check.F
     config_summary.F
     ini_parms.F
     set_defaults.F
     mom_vi_hdissip.F
     mom_vi_del2uv.F
so that Leith (approximately) only acts on the horizontally rotational part of
the flow.

WARNING: this code will only work of mom_vi_hdissip.F and mom_vi_del2uv.F are
not used by any other part of the code.  Horizontal viscosity needs to be
computed using the vector invariant formulation.  Otherwise this will not
work!!

The following parameters control how Leith that acts on the divergent part of the flow.
     viscC4leithDiv (default = 1) - Set anywhere from 0 to 1, where 1 is the 
                                    full amount of dissipation acting on the
                                    divergent part of the flow and 0 is off.
     leithDivDmask  (default = 0) - Leith is fully enabled to act on divergent flow at
                                    depths less than (i.e. shallower than) leithDivDmask
                                    (units of meters).
     leithDivFmask  (default = 0) - Leith is fully enabled to act on divergent flow in
                                    regions where the ocean floor is shallower than
                                    leithDivFmask (units of meters).

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
