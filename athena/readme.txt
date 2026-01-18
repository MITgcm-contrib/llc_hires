# downloading and checking that MITgcm runs on athena front end:
ssh athfe01
WORKDIR=/nobackup/$USER/athena
mkdir $WORKDIR
cd $WORKDIR
git clone https://github.com/MITgcm/MITgcm
git clone https://github.com/MITgcm-contrib/llc_hires
cd $WORKDIR/MITgcm
cd $WORKDIR/MITgcm/verification
./testreport -j 8 -t lab_sea

# on interactive athena node:
qsub -I -lselect=1:ncpus=256:model=tur_ath,walltime=2:00:00 -q devel
WORKDIR=/nobackup/$USER/llc_1080
cd $WORKDIR/MITgcm/verification
./testreport -j 256 -t lab_sea

# and using mpi:
cd $WORKDIR/MITgcm/verification
export LD_LIBRARY_PATH="/nasa/intel/Compiler/2022.1.0/compiler/2022.1.0/linux/compiler/lib/intel64_lin:$LD_LIBRARY_PATH"
./testreport -mpi -j 256 -of ../../llc_hires/athena/linux_amd64_cray_nas -t lab_sea
