############# run with asyncio #############
#  salloc --nodes 722 --time=24:00:00
  salloc --nodes 1040 --time=24:00:00
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
  mkdir build_4320 run_4320
  cd $SCRATCH/MITgcm/build_4320
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  cp ../../llc_hires/trillium/llc_4320/code-async/SIZE.h_108x108x20800 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_4320/code-async/linux_amd64_ifort+mpi_trillium -mpi \
  -mods '../../llc_hires/trillium/llc_4320/code-async ../../llc_hires/trillium/llc_4320/code'
  make depend
  make -j 64

#### RUN MODEL ####
  cd $SCRATCH/MITgcm/run_4320

  cp ../build_4320/mitgcmuv mitgcmuv_108x108x20800
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc4320_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  cp ../../llc_hires/trillium/llc_4320/input/* .
  unset I_MPI_PMI_LIBRARY

  mpiexec -n 21120 ./mitgcmuv_108x108x20800
