#!/bin/bash

#PBS -l select=46:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l walltime=6:00:00
#PBS -l place=scatter:excl
#PBS -q normal
#PBS -W group_list=s1353

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

#set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid

WORKDIR=/nobackup/$USER/llc_1080
cd $WORKDIR/MITgcm/run_30x30
echo $PWD
mpiexec -n 11776 ./mitgcmuv_30x30x11152_asyncio
cd $WORKDIR/MITgcm/run_30x30
sleep 5
./restart_run_auto.sh

