############# run with asyncio #############

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
  cp ../../llc_hires/trillium/llc_8640/code-async/SIZE.h_108x80x112320
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_8640/code-async/linux_amd64_gfortran_cspice_asyncio -mpi \
  -mods '../../llc_hires/trillium/llc_8640/code-async ../../llc_hires/trillium/llc_8640/code'
  make depend
  make -j

####RUN####
  salloc --nodes 722 --time=24:00:00
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_108x80x112320
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc8640_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_8640/input/* .
  mpiexec -n 138624 ./mitgcmuv_108x80x112320
