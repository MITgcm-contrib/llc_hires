#!/bin/bash -x

#PBS -l select=128:ncpus=256:mpiprocs=163:model=tur_ath
#PBS -l walltime=24:00:00
#PBS -l place=scatter:excl
#PBS -q wide
#PBS -j oe

# Define tiling configuration
RANKS=19493
TILES=_90x90x$RANKS

# Switch to ProEnv-intel instead of PrgEnv-cray
source /opt/cray/pe/modules/3.2.11.7/init/bash
module swap PrgEnv-cray PrgEnv-intel

# Set FI_PROVIDER may reduce MPI startup time 
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_CXI_DEFAULT_TX_SIZE=4096

WORKDIR=/nobackup/$USER/llc_4320
mkdir $WORKDIR/MITgcm/run$TILES
cd $WORKDIR/MITgcm/run$TILES
cp ../build$TILES/mitgcmuv mitgcmuv$TILES
cp ../../llc_hires/athena/llc_4320/input/* .
cp ../../llc_hires/athena/llc_4320/input_sal/* .
cp ../../llc_hires/athena/llc_1080/input_sal/Load_Love2_CM.dat .
cp data.exch2$TILES data.exch2

ln -sf /nobackup/kzhang/llc_4320/run_template/* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .

ulimit -s unlimited

# 8 * 163 (8 IO nodes) + 19493 (119 * 163 + 96 compute ranks) = 20797
mpiexec -n 20797 --cpu-bind none /u/scicon/tools/bin/mbind.x -cs ./mitgcmuv$TILES
