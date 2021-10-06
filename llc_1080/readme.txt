#run_template/ and forcing/ECMWF_operational/
#are also available at ECCO Drive:
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC1080/run_template
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/atmos/ECMWF_operational
#To access to ECCO Drive, a free NASA Earthdata login is required
#from https://urs.earthdata.nasa.gov/users/new


==============
# Interactive 90x90x1342 tile configuration with latest MITgcm, no asyncio
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
git clone https://github.com/MITgcm/MITgcm.git
qsub -I -q long -l select=48:ncpus=28:model=bro,walltime=120:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_90x90x1342 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run_test_noasync
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
mpiexec -n 1342 ./mitgcmuv

==============
# Interactive 90x90x1342 tile configuration with latest MITgcm, with asyncio
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
git clone https://github.com/MITgcm/MITgcm.git
qsub -I -q long -l select=52:ncpus=28:model=bro,walltime=120:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_1080/code ../../MITgcm_contrib/llc_hires/llc_1080/code-async'
make depend
make -j 56
cd ../run_test_async
cp ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
mpiexec -n 1442 ./mitgcmuv

==============
# interactive 30x30x16848 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q devel -l select=602:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_30x30 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_30x30x16848 data.exch2
mpiexec -n 16848 ./mitgcmuv &

==============
# interactive 36x36x11700 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q devel -l select=418:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_36x36 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_36x36x11700 data.exch2
mpiexec -n 11700 ./mitgcmuv &

==============
# interactive 40x40x9477 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q devel -l select=339:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_40x40 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_40x40x9477 data.exch2
mpiexec -n 9477 ./mitgcmuv &

==============
# interactive 45x45x7488 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q devel -l select=268:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_45x45 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_45x45x7488 data.exch2
mpiexec -n 7488 ./mitgcmuv &

==============
# interactive 54x54x5200 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q devel -l select=268:ncpus=28:model=bro,walltime=2:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_54x54 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_54x54x5200 data.exch2
mpiexec -n 5200 ./mitgcmuv &

==============
# Interactive 90x90x1342 tile configuration with MITgcm checkpoint66h
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint66h MITgcm_code
qsub -I -q long -l select=48:ncpus=28:model=bro,walltime=120:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_90x90x1342 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 56
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
mpiexec -n 1342 ./mitgcmuv &

==============
# interactive 90x90x1342 tile configuration from scratch
cd ~/llc_1080
cvs co MITgcm_contrib/llc_hires/llc_1080
cvs co -r checkpoint64p MITgcm_code
qsub -I -q long -l select=48:ncpus=28:model=bro,walltime=120:00:00 -m abe
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
cd ~/llc_1080/MITgcm
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_90x90x1342 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 16
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf ~dmenemen/llc_1080/MITgcm/run_2011/pick*354240* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
mpiexec -n 1342 ./mitgcmuv &

=====================
For interactive session, Ivy Bridge nodes:
qsub -I -q debug -l select=48:ncpus=28:model=bro,walltime=02:00:00 -m abe -M email
qsub -I -q devel -l select=170:ncpus=20:model=ivy,walltime=02:00:00 -m abe -M email
qsub -I -q long  -l select=170:ncpus=20:model=ivy,walltime=120:00:00 -m abe -M email
qsub -I -q long  -l select=170:ncpus=20:model=ivy,min_walltime=30:00,max_walltime=120:00:00 -m abe -M email

==============
# 60x60x2872 tile configuration

cd ~/llc_1080
cvs co -r checkpoint64p MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_1080
cd MITgcm
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.08r7 netcdf/4.0
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_60x60x2872 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_1080/code ../../MITgcm_contrib/llc_hires/llc_1080/code-async'
make depend
make -j 16
cd ~/llc_1080/MITgcm/run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_60x60x2872 data.exch2
export MPI_NUM_MEMORY_REGIONS=256
mpiexec -n 3400 ./mitgcmuv

==============
# 90x90x1342 tile configuration

cd ~/llc_1080
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_1080
cd MITgcm
module purge
module load comp-intel/2011.2 mpi-sgi/mpt.2.06r6 netcdf/4.0
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_90x90x1342 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../MITgcm_contrib/llc_hires/llc_1080/code ../../MITgcm_contrib/llc_hires/llc_1080/code-async'
make depend
make -j 16
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
#ln -sf /nobackup/dmenemen/forcing/era_interim/EIG_*_2* .
#ln -sf /nobackup/dmenemen/forcing/era_interim_corrected/EIG_dlw_sub5p_2* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
export MPI_NUM_MEMORY_REGIONS=256
mpiexec -n 1600 ./mitgcmuv

==============
# 90x90x1342 tile test configuration

cd ~/llc_1080_test
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_1080
cd MITgcm
module purge
module load comp-intel/2016.2.181 mpi-sgi/mpt.2.15r20
mkdir build run
lfs setstripe -c -1 run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_1080/code/SIZE.h_90x90x1342 SIZE.h
../tools/genmake2 -of \
 ../../MITgcm_contrib/llc_hires/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../MITgcm_contrib/llc_hires/llc_1080/code
make depend
make -j 16
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../MITgcm_contrib/llc_hires/llc_1080/input/* .
mv data.exch2_90x90x1342 data.exch2
mpiexec -n 1342 ./mitgcmuv


==============

look at output

for ts=[50760]
    fld=quikread_llc(['Eta.' myint2str(ts,10) '.data'],1080);
    clf,quikplot_llc(fld),caxis([-2.5 2]),thincolorbar
    title(ts)
    pause(.1)
end

ts=50760;
for fld={'S''T','U','V','W','HEFF'}
    tmp=quikread_llc([fld{1} '.' myint2str(ts,10) '.data'],1080);
    clf,quikplot_llc(tmp),thincolorbar
    title(fld{1})
    pause
end

==============

to determine empty tiles:
grep Empty STDOUT.*

==============

memory requirements:
nPx sNx sNy nSx node0        total         rank0  rank1
702  60  60   6 17,642,924kb 770,168,568kb
468  60  60   9 22,083,004kb 643,301,784kb
468 180 180   1 24,719,776kb 720,415,552kb 1678MB 1563MB
351  60  60  12 26,660,020kb 582,815,544kb
351 120 120   3 25,110,324kb 548,819,772kb 1711MB 1586MB
351 120 120   3  6,543,780kb  56,729,484kb - with globalFiles - run out of time
325  54  54  16 29,029,744kb 587,831,344kb
325 216 216   1 29,249,232kb 426,554,484kb - node ran out of memory and crashed
234  90  90   8 30,590,952kb 431,252,200kb - node ran out of memory and crashed
234 180 180   2 27,682,360kb 307,181,152kb - node ran out of memory and crashed

=============
factor(3240) = 2 2 2 3 3 3 3 5
factor(1080) = 2 2 2 3 3 3 5

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
2*3*3         =   18
2*2*5         =   20
2*2*2*3       =   24
3*3*3         =   27
2*3*5         =   30
2*2*3*3       =   36 * 30
2*2*2*5       =   40 * 27
3*3*5         =   45 * 24
2*3*3*3       =   54 * 20
2*2*3*5       =   60 * 18
2*2*2*3*3     =   72 * 15
2*3*3*5       =   90 * 12
2*2*3*3*3     =  108 * 10
2*2*2*3*5     =  120 *  9
3*3*3*5       =  135 *  8
2*2*3*3*5     =  180 *  6
2*2*2*3*3*3   =  216 *  5
2*3*3*3*5     =  270 *  4
2*2*2*3*3*5   =  360 *  3
2*2*3*3*3*5   =  540 *  2
