#!/bin/bash -x

#PBS -l select=10:ncpus=256:mpiprocs=248:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q normal
#PBS -j oe

# Define tiling configuration
RANKS=2229
TILES=_90x54x$RANKS

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

# Set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_CXI_DEFAULT_TX_SIZE=4096

WORKDIR=/nobackup/$USER/llc_1080
mkdir $WORKDIR/MITgcm/run$TILES
cd $WORKDIR/MITgcm/run$TILES
cp ../build$TILES/mitgcmuv mitgcmuv$TILES
cp ../../llc_hires/athena/llc_1080/input/* .
cp ../../llc_hires/athena/llc_1080/input_sal/* .
cp data_asyncio data
cp data.exch2$TILES data.exch2

ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/*JRA55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/hzhang1/pub/llc1080/*.bin .
ln -sf /nobackup/ojahn/forcing/sal/llc1080/*.bin .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

ulimit -s unlimited
# 1 * 248 (1 IO nodes) + 2229 (8 * 248 + 245 compute ranks) = 2477
mpiexec -n 2477 ./mitgcmuv$TILES
