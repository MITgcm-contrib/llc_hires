#!/bin/csh -x
#PBS -S /bin/csh
#PBS -l select=1120:ncpus=28:model=bro_ele
#PBS -q alphatst
#PBS -l walltime=12:00:00
#PBS -j oe
#PBS -m abe

cat $PBS_NODEFILE | uniq

module purge
module load comp-intel/2015.0.090 mpi-sgi/mpt.2.12r23 netcdf/4.0
cd /nobackupp1/dmenemen/llc_4320/regions/CalSWOT/run_template3b/MITgcm/run
mpiexec -n 31360 ./mitgcmuv_40x64x30720
