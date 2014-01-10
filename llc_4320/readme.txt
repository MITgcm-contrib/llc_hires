For interactive session, Ivy Bridge nodes:
qsub -I -q devel -l select=300:ncpus=20:model=ivy,walltime=02:00:00 -m abe -M email
qsub -I -q normal -l select=300:ncpus=20:model=ivy,walltime=8:00:00 -m abe -M email
qsub -I -q long -l select=300:ncpus=20:model=ivy,walltime=120:00:00 -m abe -M email
qsub -I -q long -l select=300:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M email

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
