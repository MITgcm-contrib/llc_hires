#!/bin/bash -l
#SBATCH --job-name=15x15x67392    #EDIT THE NAME OF THE CONFIGURATION
#SBATCH --mail-type=ALL
#SBATCH --nodes=351               #EDIT THE NUMBER OF NODES
#SBATCH --ntasks-per-node=192          
#SBATCH --time=24:00:00

set -euo pipefail

module load gcc/13.3 openmpi/5.0.3

JOBTAG=${SLURM_JOB_NAME}
BUILD_DIR=build_${JOBTAG}
RUN_DIR=run_${JOBTAG}

mkdir -p "$BUILD_DIR" "$RUN_DIR"

# --- Build ---
cd "$BUILD_DIR"
cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_${JOBTAG} SIZE.h

# (MPI_HOME is probably set by the module; keep only if you truly need it)
export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3

../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code/linux_amd64_gfortran_cspice \
  -mpi -mods ../../llc_hires/trillium/llc_1080/code

make depend
make -j

# --- Run directory prep ---
cd "../$RUN_DIR"
cp "../$BUILD_DIR/mitgcmuv" .

ln -sf /scratch/dmenemen/era5 .
ln -sf /scratch/dmenemen/llc1080_template/* .
ln -sf /scratch/dmenemen/SPICE/kernels .
cp -rf --remove-destination ../../llc_hires/trillium/llc_1080/input/* .
cp -rf --remove-destination ../run/data .

# Launch
time mpiexec -n 67392 ./mitgcmuv  #EDIT THE NUMBER OF CORES