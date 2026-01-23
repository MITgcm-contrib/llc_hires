#!/bin/bash

#PBS -l select=46:ncpus=256:mpiprocs=256:model=tur_ath
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

cp ../../llc_hires/athena/llc_1080/code-async/SIZE.h_30x30x11152 SIZE.h
../tools/genmake2 -mpi -mods \
 '../../llc_hires/athena/llc_1080/code-async ../../llc_hires/athena/llc_1080/code' \
 -of ../../llc_hires/athena/llc_1080/code-async/linux_amd64_ifort+mpi_cray_nas_tides_asyncio
make depend
make -j

cd $WORKDIR/MITgcm/run
echo $PWD

ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

cp ../build/mitgcmuv mitgcmuv_30x30x11152_asyncio
cp ../../llc_hires/athena/llc_1080/input/* .
cp data_asyncio data
cp data.exch2_30x30x11152 data.exch2
ln -sf /nobackup/dbwhitt/llc_1080/grid_interp_out/*glorys*on_LLC1080* .
sed -i \
 -e "s/THETA_1jan23_v4r5_on_LLC1080.bin/THETA_1jan23_glorysv4r5icecavities_on_LLC1080.bin/" \
 -e "s/SALT_1jan23_v4r5_on_LLC1080.bin/SALT_1jan23_glorys_on_LLC1080.bin/" \
 data
sed -i \
 -e "s/SIarea_1jan23_v4r5_on_LLC1080.bin/SIarea_1jan23_glorys_on_LLC1080.bin/" \
 -e "s/SIhsnow_1jan23_v4r5_on_LLC1080.bin/SIhsnow_1jan23_glorys_on_LLC1080.bin/" \
 -e "s/SIheff_1jan23_v4r5_on_LLC1080.bin/SIheff_1jan23_glorys_on_LLC1080.bin/" \
 data.seaice

mpiexec -n 11776 ./mitgcmuv_30x30x11152_asyncio
