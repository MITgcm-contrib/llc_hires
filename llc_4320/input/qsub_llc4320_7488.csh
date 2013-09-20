#!/bin/csh -x
#PBS -S /bin/csh
#PBS -l select=468:ncpus=16:model=san
#PBS -q devel
#PBS -l walltime=2:00:00
#PBS -j oe
#PBS -m abe

cat $PBS_NODEFILE | uniq

limit stacksize unlimited
module purge

module load comp-intel/2011.2 mpi-sgi/mpt.2.06a67 netcdf/4.0

mpiexec -np 7488 /u/scicon/tools/bin/gm.x ./mitgcmuv
