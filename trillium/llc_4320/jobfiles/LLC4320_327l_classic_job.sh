#!/bin/bash 
#SBATCH --nodes=128
#SBATCH --time=24:00:00
#SBATCH --job-name 327_classic_llc4320
#SBATCH --output=outputs/327_classic_llc4320_%j.txt
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kayhan.momeni1995@gmail.com  # Email address for notifications
 
cd $SCRATCH/MITgcm/run_llc4320_327l_classic/
 
module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
export MPI_HOME=$I_MPI_ROOT
unset I_MPI_PMI_LIBRARY

ulimit -s unlimited
mpiexec -n 21120 ./mitgcmuv_90x90x19493
