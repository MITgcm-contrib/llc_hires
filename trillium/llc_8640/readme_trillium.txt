############# run with asyncio #############
#  salloc --nodes 722 --time=24:00:00
  salloc --nodes 1034 --time=24:00:00
#  salloc --nodes 1211 --time=24:00:00

#### GET CODE ####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  git clone https://github.com/MITgcm/MITgcm
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd $SCRATCH/MITgcm/pkg
  ln -s $SCRATCH/llc_hires/llc_90/tides_exps/pkg_tides tides

#### BUILD MODEL ####
  cd $SCRATCH/MITgcm
  mkdir build run
  cd $SCRATCH/MITgcm/build
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  cp ../../llc_hires/trillium/llc_8640/code-async/SIZE.h_80x72x168480 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_8640/code-async/linux_amd64_ifort+mpi_trillium -mpi \
  -mods '../../llc_hires/trillium/llc_8640/code-async ../../llc_hires/trillium/llc_8640/code'
  make depend
  make -j 64

#### RUN MODEL ####
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_80x72x168480
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc8640_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_8640/input/* .
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 198528 ./mitgcmuv_80x72x168480
