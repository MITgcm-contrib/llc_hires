#!/bin/bash 
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=100
#SBATCH --cpus-per-task=1
#SBATCH --exclusive
#SBATCH --time=1:00:00
#SBATCH --job-name ECCOv4r5_tides_sal
#SBATCH --output=outputs/ECCOv4r5_tides_sal_%j.txt
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kayhan.momeni@mail.utoronto.ca  # Email address for notifications
 
cd $SCRATCH/TEST/MITgcm/run/
 
module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
export MPI_HOME=$I_MPI_ROOT
unset I_MPI_PMI_LIBRARY

mpiexec -n 113 ./mitgcmuv
