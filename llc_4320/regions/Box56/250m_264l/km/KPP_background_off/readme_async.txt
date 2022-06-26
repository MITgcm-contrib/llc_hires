This directory contains configuration details for regional simulations driven by llc4320 lateral boundary conditions.
To build and run on SciNet/Niagara, enter the following commands:

 git clone git@github.com:MITgcm-contrib/llc_hires.git
 git clone https://github.com/MITgcm/MITgcm.git
 cd MITgcm
 mkdir build run
 cd build
 module purge
 module load NiaEnv/2019b
 module load intel/2019u4
 module load openmpi
 module load hdf5/1.8.21
 module load netcdf/4.6.3
 MOD="../../llc_hires/llc_4320/regions/Box56/250m_264l/km/KPP_background_off/code_async"
 ../tools/genmake2 -of $MOD/linux_amd64_ifort+mpi_niagara -mo $MOD -mpi
 make depend
 make -j 8

# cd ../run/
# ln -s ../input/* .
# cp ../build/mitgcmuv .
# cd ..
# sbatch OpenMPIjob
