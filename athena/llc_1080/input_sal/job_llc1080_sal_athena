#!/bin/bash
#PBS -l select=9:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l place=scatter:excl
##PBS -q vlong
##PBS -l walltime=42:00:00
##PBS -q devel
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -j oe
#PBS -m abe

source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel
module use /opt/cray/pals/modulefiles
module load cray-pals

#set FI_PROVIDER may reduce MPI startup time 
FI_PROVIDER=cxi

cd $PBS_O_WORKDIR
ulimit -s unlimited
mpiexec -np 2229 ./mitgcmuv

