############# run with asyncio #############
#  salloc --nodes 21 --time=24:00:00
#  salloc --nodes 32 --time=24:00:00
#  salloc --nodes 98 --time=24:00:00
  salloc --nodes 49 --time=24:00:00

####BUILD####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  git clone https://github.com/MITgcm/MITgcm
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd $SCRATCH/MITgcm/pkg
  ln -s $SCRATCH/llc_hires/llc_90/tides_exps/pkg_tides tides
  cd $SCRATCH/MITgcm
  mkdir build run_1080_day012
  cd $SCRATCH/MITgcm/build
  module purge
  module load gcc/13.3
  module load openmpi/5.0.3
  export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3/
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_54x54x5200 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_60x72x3510 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_60x60x4212 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_30x30x16848 SIZE.h
  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_45x40x8424 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code-async/linux_amd64_gfortran_cspice_asyncio -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code-async ../../llc_hires/trillium/llc_1080/code'
  make depend
  make -j

####RUN####
  cd $SCRATCH/MITgcm/run_1080_day012
#  cp ../build/mitgcmuv mitgcmuv_54x54x5200
#  cp ../build/mitgcmuv mitgcmuv_60x72x3510
#  cp ../build/mitgcmuv mitgcmuv_60x60x4212
#  cp ../build/mitgcmuv mitgcmuv_30x30x16848
  cp ../build/mitgcmuv mitgcmuv_45x40x8424
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc1080_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_1080/input/* .
#  mv data_asyncio_day0 data
  mv data_asyncio_day012 data
  mv data.seaice_day012 data.seaice
#  mpiexec -n 6144 ./mitgcmuv_54x54x5200
#  mpiexec -n 4032 ./mitgcmuv_60x72x3510
#  mpiexec -n 4992 ./mitgcmuv_60x60x4212
#  mpiexec -n 18816 ./mitgcmuv_30x30x16848
  mpiexec -n 18816 ./mitgcmuv_45x40x8424
