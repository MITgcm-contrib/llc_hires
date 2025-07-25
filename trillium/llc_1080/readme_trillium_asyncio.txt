############# run with asyncio #############

####BUILD####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
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
  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_90x90x1872 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code-async/linux_amd64_gfortran_cspice_asyncio -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code-async ../../llc_hires/trillium/llc_1080/code'
  make depend
  make -j

####RUN####
  salloc --nodes 16 --time=24:00:00
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_90x90x1872
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc1080_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp -rf  --remove-destination ../../llc_hires/trillium/llc_1080/input/* .
  mv data_asyncio data
  mpiexec -n 3072 ./mitgcmuv_90x90x1872
