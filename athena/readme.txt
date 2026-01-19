# downloading and checking that MITgcm runs on athena front end:
ssh athfe01
WORKDIR=/nobackup/$USER/athena
mkdir $WORKDIR
cd $WORKDIR
git clone https://github.com/MITgcm/MITgcm
git clone https://github.com/MITgcm-contrib/llc_hires
cd $WORKDIR/MITgcm/verification
./testreport -j 8 -t lab_sea

# on interactive athena node:
qsub -I -lselect=1:ncpus=256:model=tur_ath,walltime=2:00:00 -q devel
WORKDIR=/nobackup/$USER/athena
cd $WORKDIR/MITgcm/verification
./testreport -j 256 -t lab_sea

# and using mpi - with PrgEnv-cray fortran setup:
export LD_LIBRARY_PATH="/nasa/intel/Compiler/2022.1.0/compiler/2022.1.0/linux/compiler/lib/intel64_lin:$LD_LIBRARY_PATH"
./testreport -mpi -j 256 -of ../../llc_hires/athena/linux_amd64_cray_nas -t lab_sea

# OR (better?) using mpi - with PrgEnv-intel fortran setup:
source /opt/cray/pe/modules/3.2.11.7/init/bash
module switch  PrgEnv-cray PrgEnv-intel
export MPICH_FC=ifort
export MPICH_CC=icc
export MPICH_CXX=icpc
module load cray-pals
module load cray-netcdf
export FI_PROVIDER=cxi
./testreport -mpi -j 256 -of ../../llc_hires/athena/linux_amd64_ifort+mpi_ice_nas_cray -t lab_sea
