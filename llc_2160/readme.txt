For interactive session, Ivy Bridge nodes:
qsub -I -q devel -l select=300:ncpus=20:model=ivy,walltime=02:00:00 -m abe -M YOUR_EMAIL_HERE
qsub -I -q normal -l select=103:ncpus=20:model=ivy,walltime=8:00:00 -m abe -M YOUR_EMAIL_HERE
qsub -I -q long -l select=300:ncpus=20:model=ivy,walltime=120:00:00 -m abe -M YOUR_EMAIL_HERE
qsub -I -q long -l select=103:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M YOUR_EMAIL_HERE

#############################
# 60x60x10882 configuration

qsub -I -q long -l select=600:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M YOUR_EMAIL_HERE
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.10r6 netcdf/4.0
cd ~/llc_2160
cvs co -r checkpoint64t MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_2160
cd MITgcm
mkdir build run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_2160/code/SIZE.h_60x60_10882 SIZE.h
cp ../../MITgcm_contrib/llc_hires/llc_2160/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 60;
    tileSizeY = 60;
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_2160/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_2160/code ../../MITgcm_contrib/llc_hires/llc_2160/code-async'
make depend
make -j 16

cd ~/llc_2160/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_60x60x10882
ln -sf /nobackup/dmenemen/tarballs/llc_2160/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/data.exch2_60x60x10882 data.exch2
emacs data

export MPI_BUFS_PER_PROC=1024
export MPI_REQUEST_MAX=65536
export MPI_GROUP_MAX=1024
export MPI_NUM_MEMORY_REGIONS=8
export MPI_UNBUFFERED_STDIO=1
export MPI_MEMMAP_OFF=1
export MPI_UD_TIMEOUT=100
mpiexec -n 12000 ./mitgcmuv_60x60x10882

tail -f STDOUT.00000 | grep advcfl_W

################################################
# 144x144x2047 configuration for grid generation

qsub -I -q devel -l select=103:ncpus=20:model=ivy,walltime=02:00:00 -m abe -M YOUR_EMAIL_HERE
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.10r6 netcdf/4.0
cd ~/llc_2160
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_2160
cd MITgcm
mkdir build run_grid
lfs setstripe -c -1 run_grid
cd build
cp ../../MITgcm_contrib/llc_hires/llc_2160/code/SIZE.h_144x144x2047 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_2160/code-async/linux_amd64_ifort+mpi_ice_nas \
 -mpi  -mods ../../MITgcm_contrib/llc_hires/llc_2160/code
make depend
make -j 16

cd ~/llc_2160/MITgcm/run_grid
cp ../build/mitgcmuv mitgcmuv_144x144x2047
ln -sf /nobackup/dmenemen/tarballs/llc_2160/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/data.exch2_144x144x2047 data.exch2

emacs data
 debuglevel=3,
 useSingleCPUio=.TRUE.,
 endtime=0.,
 deltaT = 1.,

mpiexec -n 2047 ./mitgcmuv_144x144x2047

==============

cd ~/llc_2160
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_2160
cd MITgcm
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.08r7 netcdf/4.0
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_2160/code/SIZE.h_90x90_5004 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_2160/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_2160/code ../../MITgcm_contrib/llc_hires/llc_2160/code-async'
make depend
make -j 16
cd ~/llc_2160/MITgcm/run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_2160/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/* .
mv data.exch2_90x90x5004 data.exch2
export MPI_NUM_MEMORY_REGIONS=256
mpiexec -n 6000 ./mitgcmuv

==============

look at output

for ts=[0 120 600:10:980 1080:120:2280]
    fld=quikread_llc(['Eta.' myint2str(ts,10) '.data'],2160);
    clf,quikplot_llc(fld),caxis([-2.5 2]),thincolorbar
    title(ts)
    pause(.1)
end

==============

to determine empty tiles:
grep Empty STDOUT.* > empty.txt

==============

# generate 30x30 blank tiles
qsub -I -q normal -l select=339:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
cd ~/llc_2160/MITgcm
mkdir run_30x30
lfs setstripe -c -1 run_30x30
cd build
rm *
cp ../../MITgcm_contrib/llc_hires/llc_2160/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 30;
    tileSizeY = 30;
cp ../../MITgcm_contrib/llc_hires/llc_2160/code/SIZE.h_60x60_10882 SIZE.h
emacs SIZE.h
     &           sNx =  30,
     &           sNy =  30,
     &           nSx =   8,
     &           nPx = 8424,
     &           Nr  =  2 )
cp ../../MITgcm_contrib/llc_hires/llc_2160/code-async/eeboot_minimal.F .
emacs eeboot_minimal.F
C         standardMessageUnit=errorMessageUnit
         WRITE(fNam,'(A,A)') 'STDOUT.', myProcessStr(1:5)
         OPEN(standardMessageUnit,FILE=fNam,STATUS='unknown')
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_2160/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_2160/code ../../MITgcm_contrib/llc_hires/llc_2160/code-async'
make depend
make -j 16
cd ~/llc_2160/MITgcm/run_30x30
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_2160/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_2160/input/* .
mv data.exch2_144x144x2047 data.exch2
emacs data.exch2
# remove the blank tile list
emacs data
 tRef =  18.89, 18.89,
 sRef =  34.84, 34.84,
 endtime=45.,
 delR =   1.00,    1.14,
# hydrogThetaFile='THETA_llc1080_14jan2011_2160x28080x90_r4',
# hydrogSaltFile ='SALT_llc1080_14jan2011_2160x28080x90_r4',
# uVelInitFile   ='UVEL_llc1080_14jan2011_2160x28080x90_r4',
# vVelInitFile   ='VVEL_llc1080_14jan2011_2160x28080x90_r4',
# pSurfInitFile  ='ETAN_llc1080_14jan2011_2160x28080_r4',
mpiexec -n 9492 ./mitgcmuv

==============

memory requirements:
nPx  sNx sNy nSx cpu node0        total           rank0 rankm
936  180 180   2 san node ran out of memory and crashed with singlecpuio
1053 240 240   1 san node ran out of memory and crashed with singlecpuio
1300 216 216   1 san node ran out of memory and crashed with singlecpuio
1872 180 180   1 wes node ran out of memory and crashed with singlecpuio
1872 180 180   1 wes 21,377,644kb 3,294,676,080kb node ran out of memory with singlecpuio and bigmem=true:mem=90GB for node 0
1872 180 180   1 san node ran out of memory and crashed with singlecpuio
1872 180 180   1 san 11,558,588kb 1,356,676,140kb singlecpuio=.FALSE.
2925 144 144   1 san  8,374,668kb 1,538,454,112kb 886MB 892MB singlecpuio=.FALSE.
2925 144 144   1 san 27,284,996kb 4,942,949,704kb node ran out of memory and crashed with singlecpuio
3328 135 135   1 san rank 0 run out of memory
3328 135 135   1 san some random node run out of memory (full node for rank 0)
4212 120 120   1 san node ran out of memory
5200 108 108   1 san node ran out of memory

=============

2             =    2
3             =    3
2*2           =    4
5             =    5
2*3           =    6
2*2*2         =    8
3*3           =    9
2*5           =   10
2*2*3         =   12
3*5           =   15
2*2*2*2       =   16
2*3*3         =   18
2*2*5         =   20
2*2*2*3       =   24
3*3*3         =   27
2*3*5         =   30
2*2*3*3       =   36
2*2*2*5       =   40
3*3*5         =   45
2*2*2*2*3     =   48 * 45
2*3*3*3       =   54 * 40
2*2*3*5       =   60 * 36
2*2*2*3*3     =   72 * 30
2*2*2*2*5     =   80 * 27
2*3*3*5       =   90 * 24
2*2*3*3*3     =  108 * 20
2*2*2*3*5     =  120 * 18
3*3*3*5       =  135 * 16
2*2*2*2*3*3   =  144 * 15
2*2*3*3*5     =  180 * 12
2*2*2*3*3*3   =  216 * 10
2*2*2*2*3*5   =  240 *  9
2*3*3*3*5     =  270 *  8
2*2*2*3*3*5   =  360 *  6
2*2*2*2*3*3*3 =  432 *  5
2*2*3*3*3*5   =  540 *  4
2*2*2*2*3*3*5 =  720 *  3
2*2*2*3*3*3*5 = 1080 *  2
