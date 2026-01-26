#!/bin/bash -x

#PBS -l select=115:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q wide

# define tiling configuration
RANKS=29271
TILES=_72x72x$RANKS

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

#set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid

WORKDIR=/nobackup/$USER/llc_4320
cd $WORKDIR/MITgcm

mv run run_old
mv build build_old
mkdir build run

cd $WORKDIR/MITgcm/build

cp ../../llc_hires/athena/llc_4320/code/SIZE.h_$TILES SIZE.h
../tools/genmake2 -mpi -mods ../../llc_hires/athena/llc_4320/code \
 -of ../../llc_hires/athena/llc_4320/code/linux_amd64_ifort+mpi_cray_nas_tides
make depend
make -j

cd $WORKDIR/MITgcm/run
echo $PWD

cp ../build/mitgcmuv mitgcmuv_$TILES_asyncio
cp ../../llc_hires/athena/llc_4320/input/* .
cp data.exch2_$TILES data.exch2
sed -i \
 -e "s/# usesinglecpuio=.TRUE.,/ usesinglecpuio=.TRUE.,/" \
 data

ln -sf /nobackup/kzhang/llc_4320/run_template/* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

mpiexec -n $RANKS ./mitgcmuv$TILES
