This directory contains configuration details for regional simulations driven
by llc4320 lateral boundary conditions.

To build and run on pleiades, enter the following commands in the build folder
of the project:

 git clone git@github.com:MITgcm-contrib/llc_hires.git
 git clone https://github.com/MITgcm/MITgcm.git
 cd MITgcm
 mkdir build run
 cd build
 module purge
 module load comp-intel/2020.4.304  mpi-hpe/mpt.2.25 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
 MOD="../../llc_hires/llc_4320/regions/Box56/250m_264l/code_async"
 ../tools/genmake2 -of $MOD/linux_amd64_ifort+mpi_ice_nas -mo $MOD -mpi
 make depend
 make -j 16

#cd ../run/
#ln -s ../input/* .
#cp ../build/mitgcmuv .
#cd ..
# sbatch OpenMPIjob
