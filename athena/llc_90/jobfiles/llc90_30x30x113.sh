#!/bin/bash -x

#PBS -l select=2:ncpus=256:mpiprocs=113:model=tur_ath
#PBS -l walltime=2:00:00
#PBS -l place=scatter:excl
#PBS -q normal
#PBS -j oe

# Define tiling configuration
RANKS=113
TILES=_30x30x$RANKS

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

# Set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_CXI_DEFAULT_TX_SIZE=4096

WORKDIR=/nobackup/$USER/llc_90
mkdir $WORKDIR/MITgcm/run$TILES
cd $WORKDIR/MITgcm/run$TILES
cp ../build$TILES/mitgcmuv mitgcmuv$TILES
cp ../../llc_hires/athena/llc_90/input/* .
cp ../../llc_hires/athena/llc_90/input_sal/* .

INPUTDIR='/nobackup/hzhang1/pub/Release5'
ln -s $INPUTDIR/input_bin/tile* .
ln -s $INPUTDIR/input_bin/ICE* .
ln -s $INPUTDIR/input_bin/BATHY* .
ln -s $INPUTDIR/input_bin/*_2050212_dailymean.bin .
ln -sf /nobackup/kzhang/llc1080/run_template/*JRA55* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

ulimit -s unlimited
# 1 * 113 (1 IO nodes) + 113 (1 * 113 + 0 compute ranks) = 226
mpiexec -n 226 ./mitgcmuv$TILES
