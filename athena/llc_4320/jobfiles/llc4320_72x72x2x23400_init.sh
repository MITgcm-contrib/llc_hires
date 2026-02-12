#!/bin/bash -x

#PBS -l select=117:ncpus=256:mpiprocs=256:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q wide

# define tiling configuration
RANKS=23400
TILES=_72x72x2x$RANKS

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

#set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_CXI_DEFAULT_TX_SIZE=4096

WORKDIR=/nobackup/$USER/llc_4320
cd $WORKDIR/MITgcm

mkdir build$TILES run$TILES

cd $WORKDIR/MITgcm/build$TILES

cp ../../llc_hires/athena/llc_4320/code/SIZE.h$TILES SIZE.h
../tools/genmake2 -mpi -mods ../../llc_hires/athena/llc_4320/code \
 -of ../../llc_hires/athena/llc_4320/code/linux_amd64_ifort+mpi_cray_nas_tides
make depend
make -j

cd $WORKDIR/MITgcm/run$TILES

cp ../build$TILES/mitgcmuv mitgcmuv$TILES
cp ../../llc_hires/athena/llc_4320/input/* .
cp data_init data
cp data.pkg_init data.pkg

ln -sf /nobackup/kzhang/llc_4320/run_template/* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .

mpiexec -n $RANKS ./mitgcmuv$TILES
