############# run with asyncio #############
#  salloc --nodes 722 --time=24:00:00
  salloc --nodes 1034 --time=24:00:00
#  salloc --nodes 1211 --time=24:00:00

####BUILD####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  git clone https://github.com/MITgcm/MITgcm
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd $SCRATCH/MITgcm/pkg
  ln -s $SCRATCH/llc_hires/llc_90/tides_exps/pkg_tides tides
  cd $SCRATCH/MITgcm
  mkdir build run
  cd $SCRATCH/MITgcm/build
  module purge
  module load gcc/13.3
  module load openmpi/5.0.3
  export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3/
  cp ../../llc_hires/trillium/llc_8640/code-async/SIZE.h_80x72x168480 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_8640/code-async/linux_amd64_gfortran_cspice_asyncio -mpi \
  -mods '../../llc_hires/trillium/llc_8640/code-async ../../llc_hires/trillium/llc_8640/code'
  make depend
  make -j

####RUN####
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_80x72x168480
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc8640_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_8640/input/* .
#  mpiexec -n 198528 ./mitgcmuv_80x72x168480
  mpirun --mca fs_ufs_lock_algorithm 1 -x LD_VAST_PATHFILE=vastpreload.paths -x LD_PRELOAD=/scinet/vast/vast-preload-lib/lib/libvastpreload.so -x LD_VAST_LOG_TOPICS=2 -np 198528 ./mitgcmuv_80x72x168480
