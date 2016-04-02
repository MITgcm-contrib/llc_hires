#############################
# 90x90x19023 configuration

qsub -I -q alphatst -l select=850:ncpus=24:model=has,walltime=8:00:00 -m abe -M menemenlis@me.com

module purge
module load comp-intel/2015.0.090 test/mpt.2.11r8 netcdf/4.0

cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_90x90x19023 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 90;
    tileSizeY = 90;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16

cd ~/llc_4320/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_90x90x19023_intel.2015.0.090
cp data.exch2_90x90x19023 data.exch2

cd ~/llc_4320/MITgcm/run
mv STDOUT.00000 STDOUT.409536
emacs data
 nIter0=409536,
mv pickup_0000409536.data pickup.0000409536.data
mv pickup_0000409536.meta pickup.0000409536.meta
mv pickup_seaice_0000409536.data pickup_seaice.0000409536.data
mv pickup_seaice_0000409536.meta pickup_seaice.0000409536.meta

cd ~/llc_4320/MITgcm/run
module purge
module load comp-intel/2015.0.090 test/mpt.2.11r8 netcdf/4.0
cp data.exch2_90x90x19023 data.exch2
mpiexec -n 20400 ./mitgcmuv_90x90x19023_intel.2015.0.090

tail -f STDOUT.00000 | grep advcfl_W


#############################
qsub -I -q alphatst -l select=850:ncpus=24:model=has,walltime=8:00:00 -m abe -M menemenlis@me.com
qsub -I -q alphatst -l select=497:ncpus=24:model=has,walltime=8:00:00 -m abe -M menemenlis@me.com

qsub -I -q alphatst -l select=497:ncpus=24:model=has,walltime=8:00:00 -m abe -M menemenlis@me.com
module purge
module load comp-intel/2015.0.090 mpi-sgi/mpt.2.10r6 netcdf/4.0

module load comp-intel/2015.0.090 test/mpt.2.11r8 netcdf/4.0

cd ~/llc_4320/MITgcm/build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_120x120x19023 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 120;
    tileSizeY = 120;
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas .
emacs linux_amd64_ifort+mpi_ice_nas
    FOPTIM='-O3 -ipo -axCORE-AVX2,AVX -xSSE4.1 -ip -fp-model precise -traceback -ftz'
../tools/genmake2 -of linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16

cd ~/llc_4320/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_120x120x10901_AVX2

mv STDOUT.00000 STDOUT.428544
emacs data
 nIter0=428544,
mv pickup_0000428544.data pickup.0000428544.data
mv pickup_0000428544.meta pickup.0000428544.meta
mv pickup_seaice_0000428544.data pickup_seaice.0000428544.data
mv pickup_seaice_0000428544.meta pickup_seaice.0000428544.meta

cd ~/llc_4320/MITgcm/run
module purge
module load comp-intel/2015.0.090 test/mpt.2.11r8 netcdf/4.0
cp data.exch2_120x120x10901 data.exch2
mpiexec -n 12000 ./mitgcmuv_120x120x10901_Avx2


For interactive session, Ivy Bridge nodes:
qsub -I -q devel -l select=300:ncpus=20:model=ivy,walltime=02:00:00 -m abe -M email
qsub -I -q normal -l select=300:ncpus=20:model=ivy,walltime=8:00:00 -m abe -M email
qsub -I -q long -l select=300:ncpus=20:model=ivy,walltime=120:00:00 -m abe -M email

#############################
# 90x90x19023 configuration

qsub -I -q long -l select=1020:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M menemenlis@me.com
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.10r6 netcdf/4.0
cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_90x90x19023 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 90;
    tileSizeY = 90;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16

cd ~/llc_4320/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_90x90x19023
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
cp data.exch2_90x90x19023 data.exch2
emacs data

export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 20400 ./mitgcmuv_90x90x19023

tail -f STDOUT.00000 | grep advcfl_W

#############################
# 48x48x64670 configuration

module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.10r6 netcdf/4.0
cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_48x48x64670 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 48;
    tileSizeY = 48;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16

cd ~/llc_4320/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_48x48x64670
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/data.exch2_90x90x19023 data.exch2

#############################
# generate 60x60 blank tiles
qsub -I -q long -l select=600:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M menemenlis@me.com
module purge
module load  comp-intel/2012.0.032 netcdf/4.0
module use -a ~kjtaylor/modulefiles
module load sles11sp3/mpt-2.10-nasa201311271217
cd ~/llc_4320/MITgcm
mkdir run_60x60
lfs setstripe -c -1 run_60x60
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 60;
    tileSizeY = 60;
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_120x120x10901 SIZE.h
emacs SIZE.h
     &           sNx =  60,
     &           sNy =  60,
     &           nSx =   6,
     &           nPx = 11232,
     &           Nr  =  2 )
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/eeboot_minimal.F .
emacs eeboot_minimal.F
C         standardMessageUnit=errorMessageUnit
         WRITE(fNam,'(A,A)') 'STDOUT.', myProcessStr(1:5)
         OPEN(standardMessageUnit,FILE=fNam,STATUS='unknown')
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cd ~/llc_4320/MITgcm/run_60x60
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_120x120x10901 data.exch2
emacs data
 tRef =  18.89, 18.89,
 sRef =  34.84, 34.84,
 endtime=20.,
 delR =   1.00,    1.14,
# hydrogThetaFile='THETA_llc2160_10sep2011_4320x56160x90_r4',
# hydrogSaltFile ='SALT_llc2160_10sep2011_4320x56160x90_r4',
# uVelInitFile   ='UVEL_llc2160_10sep2011_4320x56160x90_r4',
# vVelInitFile   ='VVEL_llc2160_10sep2011_4320x56160x90_r4',
# pSurfInitFile  ='ETAN_llc2160_10sep2011_4320x56160_r4',
emacs data.exch2
# remove the blank tile list
export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 12000 ./mitgcmuv

#############################
# generate 45x45 blank tiles
qsub -I -q long -l select=600:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M menemenlis@me.com
module purge
module load  comp-intel/2012.0.032 netcdf/4.0
module use -a ~kjtaylor/modulefiles
module load sles11sp3/mpt-2.10-nasa201311271217
cd ~/llc_4320/MITgcm
mkdir run_45x45
lfs setstripe -c -1 run_45x45
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 45;
    tileSizeY = 45;
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_120x120x10901 SIZE.h
emacs SIZE.h
     &           sNx =  45,
     &           sNy =  45,
     &           nSx =  12,
     &           nPx = 9984,
     &           Nr  =  2 )
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/eeboot_minimal.F .
emacs eeboot_minimal.F
C         standardMessageUnit=errorMessageUnit
         WRITE(fNam,'(A,A)') 'STDOUT.', myProcessStr(1:5)
         OPEN(standardMessageUnit,FILE=fNam,STATUS='unknown')
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cd ~/llc_4320/MITgcm/run_45x45
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_120x120x10901 data.exch2
emacs data
 tRef =  18.89, 18.89,
 sRef =  34.84, 34.84,
 endtime=20.,
 delR =   1.00,    1.14,
# hydrogThetaFile='THETA_llc2160_10sep2011_4320x56160x90_r4',
# hydrogSaltFile ='SALT_llc2160_10sep2011_4320x56160x90_r4',
# uVelInitFile   ='UVEL_llc2160_10sep2011_4320x56160x90_r4',
# vVelInitFile   ='VVEL_llc2160_10sep2011_4320x56160x90_r4',
# pSurfInitFile  ='ETAN_llc2160_10sep2011_4320x56160_r4',
emacs data.exch2
# remove the blank tile list
export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 12000 ./mitgcmuv

#############################
# generate 48x48 blank tiles
qsub -I -q devel -l select=600:ncpus=20:model=ivy,walltime=2:00:00 -m abe -M menemenlis@me.com
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.10r6 netcdf/4.0
cd ~/llc_4320/MITgcm
mkdir run_48x48
lfs setstripe -c -1 run_48x48
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 48;
    tileSizeY = 48;
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_120x120x10901 SIZE.h
emacs SIZE.h
     &           sNx =  48,
     &           sNy =  48,
     &           nSx =  10,
     &           nPx = 10530,
     &           Nr  =  2 )
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/eeboot_minimal.F .
emacs eeboot_minimal.F
C         standardMessageUnit=errorMessageUnit
         WRITE(fNam,'(A,A)') 'STDOUT.', myProcessStr(1:5)
         OPEN(standardMessageUnit,FILE=fNam,STATUS='unknown')
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cd ~/llc_4320/MITgcm/run_48x48
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_120x120x10901 data.exch2
emacs data.exch2
# remove blankList
emacs data
 tRef =  18.89, 18.89,
 sRef =  34.84, 34.84,
 endtime=20.,
 delR =   1.00,    1.14,
# hydrogThetaFile='THETA_llc2160_10sep2011_4320x56160x90_r4',
# hydrogSaltFile ='SALT_llc2160_10sep2011_4320x56160x90_r4',
# uVelInitFile   ='UVEL_llc2160_10sep2011_4320x56160x90_r4',
# vVelInitFile   ='VVEL_llc2160_10sep2011_4320x56160x90_r4',
# pSurfInitFile  ='ETAN_llc2160_10sep2011_4320x56160_r4',
export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 12000 ./mitgcmuv

#############################
# 120x120x10901 configuration

qsub -I -q long -l select=600:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M menemenlis@me.com
module purge
module load  comp-intel/2012.0.032 netcdf/4.0
module use -a ~kjtaylor/modulefiles
module load sles11sp3/mpt-2.10-nasa201311271217
cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
cd MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_120x120x10901 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 120;
    tileSizeY = 120;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16

cd ~/llc_4320/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_120x120x10901
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_120x120x10901 data.exch2
emacs data

export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 12000 ./mitgcmuv_120x120x10901

tail -f STDOUT.00000 | grep advcfl_W

==============

qsub -I -q R3089666 -l select=1750:model=ivy:aoe=sles11,walltime=04:00:00
tcsh
cd ~/llc_4320/MITgcm
mkdir run
lfs setstripe -c -1 run
cd run
cat $PBS_NODEFILE | awk '{for (i=0;i<20;++i) print $0}' > mynodes
setenv PBS_NODEFILE mynodes
cp /nobackupp8/chenze/run/mitgcmuv_72x72x29297 .
ln -sf /nobackupp8/chenze/run/pickup_seaice_0000000360.meta pickup_seaice.0000000180.meta
ln -sf /nobackupp8/chenze/run/pickup_seaice_0000000360.data pickup_seaice.0000000180.data
ln -sf /nobackupp8/chenze/run/pickup_0000000360.meta pickup.0000000180.meta
ln -sf /nobackupp8/chenze/run/pickup_0000000360.data pickup.0000000180.data
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_72x72x29297 data.exch2
module purge
module load  comp-intel/2012.0.032 netcdf/4.0
module use -a ~kjtaylor/modulefiles
module load sles11sp3/mpt-2.10-nasa201311271217
setenv MPI_BUFS_PER_PROC 512
setenv MPI_REQUEST_MAX 65536
setenv MPI_GROUP_MAX 1024
setenv MPI_NUM_MEMORY_REGIONS 8
setenv MPI_UNBUFFERED_STDIO 1
setenv MPI_MEMMAP_OFF 1
export MPI_UD_TIMEOUT=100

mpiexec -n 35000 ./mitgcmuv_72x72x29297

tail -f STDOUT.00000 | grep advcfl_w

==============

cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
# set correct tileSizeX and tileSizeY in MITgcm_contrib/llc_hires/llc_4320/cpde-asyn/readtile_mpiio.c
cd MITgcm
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.08r7 netcdf/4.0
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_72x72x29297 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cd ../run
cp ../build/mitgcmuv mitgcmuv_72x72x29297
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_72x72x29297 data.exch2
export MPI_NUM_MEMORY_REGIONS=256
mpiexec -n 35000 ./mitgcmuv_72x72x29297

tail -f STDOUT.00000 | grep advcfl_w

==============

cd ~/llc_4320
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_4320
# set correct tileSizeX and tileSizeY in MITgcm_contrib/llc_hires/llc_4320/cpde-asyn/readtile_mpiio.c
cd MITgcm
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.08r7 netcdf/4.0
mkdir build run_180x180x5015
lfs setstripe -c -1 run_180x180x5015
cd build
cp ../../MITgcm_contrib/llc_hires/llc_4320/code/SIZE.h_180x180x5015 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_4320/code ../../MITgcm_contrib/llc_hires/llc_4320/code-async'
make depend
make -j 16
cd ../run_180x180x5015
cp ../build/mitgcmuv mitgcmuv_180x180x5015
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_4320/input/* .
mv data.exch2_72x72x29297 data.exch2
export MPI_NUM_MEMORY_REGIONS=256
mpiexec -n 6000 ./mitgcmuv_180x180x5015

==============

look at output

for ts=[0 120 600:10:980 1080:120:2280]
    fld=quikread_llc(['Eta.' myint2str(ts,10) '.data'],4320);
    clf,quikplot_llc(fld),caxis([-2.5 2]),thincolorbar
    title(ts)
    pause(.1)
end

==============

to determine empty tiles:
grep Empty STDOUT.*

=============

memory requirements:
nPx  sNx sNy nSx cpu node0        total
3744 180 180   2 san 22,106,128kb 5,195,641,224kb - node ran out of memory and crashed
5616 120 120   3 san - node ran out of memory and crashed
7488 180 180   1 san 

=============

2               =    2
3               =    3
2*2             =    4
5               =    5
2*3             =    6
2*2*2           =    8
3*3             =    9
2*5             =   10
2*2*3           =   12
3*5             =   15
2*2*2*2         =   16
2*3*3           =   18
2*2*5           =   20
2*2*2*3         =   24
3*3*3           =   27
2*3*5           =   30
2*2*2*2*2       =   32
2*2*3*3         =   36
2*2*2*5         =   40
3*3*5           =   45
2*2*2*2*3       =   48
2*3*3*3         =   54
2*2*3*5         =   60
2*2*2*3*3       =   72 * 60
2*2*2*2*5       =   80 * 54
2*3*3*5         =   90 * 48
2*2*2*2*2*3     =   96 * 45
2*2*3*3*3       =  108 * 40
2*2*2*3*5       =  120 * 36
3*3*3*5         =  135 * 32
2*2*2*2*3*3     =  144 * 30
2*2*2*2*2*5     =  160 * 27
2*2*3*3*5       =  180 * 24
2*2*2*3*3*3     =  216 * 20
2*2*2*2*3*5     =  240 * 18
2*3*3*3*5       =  270 * 16
2*2*2*2*2*3*3   =  288 * 15
2*2*2*3*3*5     =  360 * 12
2*2*2*2*3*3*3   =  432 * 10
2*2*2*2*2*3*5   =  480 *  9
2*2*3*3*3*5     =  540 *  8
2*2*2*2*3*3*5   =  720 *  6
2*2*2*2*2*3*3*3 =  864 *  5
2*2*2*3*3*3*5   = 1080 *  4
2*2*2*2*2*3*3*5 = 1440 *  3
2*2*2*2*3*3*3*5 = 2160 *  2
