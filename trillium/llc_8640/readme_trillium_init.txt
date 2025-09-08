############# run without asyncio #############
# to save grid information and find blank tiles
  salloc --nodes 3 --time=2:00:00

#### BUILD ####
  cd $SCRATCH
  git clone https://github.com/MITgcm/MITgcm
  git clone https://github.com/MITgcm-contrib/llc_hires
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd $SCRATCH/MITgcm/pkg
  ln -s $SCRATCH/llc_hires/llc_90/tides_exps/pkg_tides tides
  cd $SCRATCH/MITgcm
  mkdir build run
  cd $SCRATCH/MITgcm/build
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  cp ../../llc_hires/trillium/llc_8640/code/SIZE.h_108x108x160x520 SIZE.h
  ../tools/genmake2 -of \
    ../../llc_hires/trillium/llc_8640/code/linux_amd64_ifort+mpi_trillium \
    -mpi -mods ../../llc_hires/trillium/llc_8640/code
  make depend
  make -j 64

#### RUN ####
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_108x108x160x520
  ln -sf /project/rrg-peltier-ac/momenika/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/dmenemen/llc8640_template/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_8640/input/* .
  cp data_init data
  cp data.pkg_init data.pkg
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 520 ./mitgcmuv_108x108x160x520
