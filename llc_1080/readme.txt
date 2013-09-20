For interactive session, Ivy Bridge nodes:
qsub -I -q devel -l select=24:ncpus=20:model=ivy,walltime=02:00:00
qsub -I -q long -l select=24:ncpus=20:model=ivy,walltime=120:00:00

For batch submission:
qsub -q devel -l select=24:ncpus=20:model=ivy,walltime=02:00:00 runscript
qsub qsub_llc1080_468.csh 

These will give you 24 x 20 = 480 cores. Launch 468 ranks with

==============

cvs co MITgcm_code
cd MITgcm
module purge
module load comp-intel/2011.2 mpi-sgi/mpt.2.06a67 netcdf/4.0
#module load comp-intel/2011.7.256 mpi-sgi/mpt.2.08r7 netcdf/4.0
mkdir build run
cd build
../tools/genmake2 -of ~/tarballs/llc_1080/code/linux_amd64_ifort+mpi_ice_nas -mpi -mods ~/tarballs/llc_1080/code
make depend
make -j 16
cd ../run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/* .
ln -sf /nobackup/dmenemen/forcing/era_interim/EIG_*_2* .
ln -sf /nobackup/dmenemen/forcing/era_interim_corrected/EIG_dlw_sub5p_2* .
cp /nobackup/dmenemen/tarballs/llc_1080/input/* .
mpiexec -n 379 ./mitgcmuv

==============

look at output

for ts=[1920:240:8880]
    fld=quikread_llc(['Eta.' myint2str(ts,10) '.data'],1080);
    clf,quikplot_llc(fld),caxis([-2.5 2]),thincolorbar
    title(ts)
    pause(.1)
end

ts=14040;
for fld={'S','T','U','V','W','HEFF'}
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
