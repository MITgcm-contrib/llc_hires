#!/bin/bash

#PBS -l select=66:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q wide

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

cp ../../llc_hires/athena/llc_1080/code/SIZE.h_30x30x16848 SIZE.h
../tools/genmake2 -mpi -mods ../../llc_hires/athena/llc_1080/code \
 -of ../../llc_hires/athena/llc_1080/code/linux_amd64_ifort+mpi_cray_nas_tides
make depend
make -j

cd $WORKDIR/MITgcm/run
echo $PWD

cp ../build/mitgcmuv mitgcmuv_30x30x16848
cp ../../llc_hires/athena/llc_1080/input/* .
cp data_init data

ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

mpiexec -n 2560 ./mitgcmuv_30x30x16848
