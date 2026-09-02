############# run with asyncio #############
#  salloc --nodes  128 --time=24:00:00
#  salloc --nodes  722 --time=24:00:00
#  salloc --nodes 1040 --time=24:00:00
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
  MOD=$SCRATCH/llc_hires/trillium/llc_4320
  cp $MOD/code-async/SIZE.h_90x90x19493 SIZE.h
  ../tools/genmake2 -of \
  $MOD/code-sal/linux_amd64_ifort+mpi_trillium_shtns_asyncio -mpi \
  -mods "$MOD/code-sal $MOD/code-async $MOD/code"
  make depend
  make -j 64

#### RUN MODEL ####
  cd $SCRATCH/MITgcm/run_4320

  MOD=$SCRATCH/llc_hires/trillium/llc_4320
  cp ../build_4320/mitgcmuv mitgcmuv_90x90x19493
  ln -sf /project/rrg-peltier-ac/momenika/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/momenika/llc4320_template/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  find ../../llc_hires/trillium/llc_4320/input/ -type f -exec cp -t . -- {} +
  cp $MOD/input-sal/* .

  cp -f data_327l_classic_dy182hr00 data
  cp -f data.seaice_327l_classic_dy182hr00 data.seaice
  cp -f data.kpp_327l_classic data.kpp
  cp -f data.exch2_90x90x19493 data.exch2
  
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 21120 ./mitgcmuv_90x90x19493
 
#  unset I_MPI_PMI_LIBRARY
#  mpiexec -n 21120 ./mitgcmuv_90x90x19493
  $MOD/jobfiles/LLC4320_327l_classic_job.sh
