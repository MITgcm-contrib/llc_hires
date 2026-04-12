This version of LLC90 Includes Tides and Sal and asyncio and all complexities.

# 1. These instructions are specific to SciNet Trillium

# 2. Get code
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  git clone https://github.com/MITgcm/MITgcm
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd $SCRATCH/MITgcm/pkg
  ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
  ln -s ../../llc_hires/llc_90/tides_exps/pkg_sal   sal

# 3. Build executable
  mkdir $SCRATCH/MITgcm/build
  cd $SCRATCH/MITgcm/build
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  MOD=$SCRATCH/llc_hires/athena/llc_90
  ../tools/genmake2 -mpi -mods "$MOD/code-async $MOD/code" \
   -of /project/rrg-peltier-ac/momenika/linux_amd64_ifort+mpi_trillium
  make depend
  make -j 64

# 4. Run simulation (1992-2019 period)
  mkdir $SCRATCH/MITgcm/run
  cd $SCRATCH/MITgcm/run
  ln -sf ../build/mitgcmuv .
  ln -sf /scratch/dmenemen/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  ln -sf /project/rrg-peltier-ac/momenika/Release5/input_bin/* .
  cp -sf $MOD/input/* .



  #IMPORTANT 1:
  #Change sal_model2llFile in $SCRATCH/MITgcm/run/data.sal
  # from '/nobackup/ojahn/forcing/sal/llc90/llc90_to_GL84x48XC0NS_conservative' 
  # to '/project/rrg-peltier-ac/momenika/sal/llc90/llc90_to_GL84x48XC0NS_conservative'

  #IMPORTANT 2:
  #Change KERNELS_TO_LOAD in $SCRATCH/MITgcm/run/meta_kernel
  # from /nobackup/dmenemen/forcing/SPICE/*
  # to /project/rrg-peltier-ac/momenika/SPICE/*
  #This should be done one by one for all kernels.

  #IMPORTANT 2:
  #Comment out this line:
  #runoftempfile     = 'wattmp_clim366_JRA55_do',
  #in data.exf


  salloc --nodes 2 --time 24:00:00
  cd $SCRATCH/MITgcm/run
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 384 ./mitgcmuv
