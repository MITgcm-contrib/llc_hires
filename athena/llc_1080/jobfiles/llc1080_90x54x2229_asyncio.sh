#!/bin/bash

#PBS -l select=10:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q normal

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

#set FI_PROVIDER may reduce MPI startup time 
FI_PROVIDER=cxi

WORKDIR=/nobackup/$USER/llc_1080
cd $WORKDIR/MITgcm
echo $PWD

mv run run_old
mv build build_old
mkdir build run

cd $WORKDIR/MITgcm/build
echo $PWD

cp ../../llc_hires/athena/llc_1080/code-async/SIZE.h_90x54x2229 SIZE.h
../tools/genmake2 -mpi -mods \
 '../../llc_hires/athena/llc_1080/code-async ../../llc_hires/athena/llc_1080/code' \
 -of ../../llc_hires/athena/llc_1080/code-async/linux_amd64_ifort+mpi_cray_nas_tides_asyncio
make depend
make -j

cd $WORKDIR/MITgcm/run
echo $PWD

cp ../build/mitgcmuv mitgcmuv_90x54x2229_asyncio
cp ../../llc_hires/athena/llc_1080/input/* .
cp data_asyncio data
cp data.exch2_90x54x2229 data.exch2

ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

mpiexec -n 2560 ./mitgcmuv_90x54x2229_asyncio
