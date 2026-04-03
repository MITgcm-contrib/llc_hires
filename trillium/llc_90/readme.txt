# ECCO Version 4 Release 5 (V4r5) with tides and self-attraction and loading based on:
# https://github.com/MITgcm-contrib/llc_hires/blob/master/llc_90/ecco_v4r5/readme_v4r5_68y.txt

# 1. These instructions are specific to SciNet Trillium

# 2. Get code
  cd $SCRATCH
  git clone --depth 1 -b checkpoint68y https://github.com/MITgcm/MITgcm.git
  git clone https://github.com/ECCO-Summer-School/ESS25-Team_TOTS.git
  cd $WORKDIR/MITgcm/pkg
  ln -sf ../../ESS25-Team_TOTS/sal .
  ln -sf ../../ESS25-Team_TOTS/tides .

# 3. Build executable
  mkdir $SCRATCH/MITgcm/build
  cd $SCRATCH/MITgcm/build
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  MOD=$SCRATCH/ESS25-Team_TOTS/ECCOv4r5_tides_sal
  ../tools/genmake2 -mpi -mods $MOD/code \
   -of /project/rrg-peltier-ac/momenika/linux_amd64_ifort+mpi_trillium
  make depend
  make -j 64

# 4. Run simulation (1992-2019 period)
  mkdir $SCRATCH/MITgcm/run
  cd $SCRATCH/MITgcm/run
  mkdir -p diags
  ln -sf ../build/mitgcmuv .
  INPUTDIR='/project/rrg-peltier-ac/momenika/Release5'
  ln -s $INPUTDIR/input_bin/* .
  ln -s $INPUTDIR/TBADJ .
  cp -r $MOD/input/* .

  #IMPORTANT 1:
  #Change sal_model2llFile in $SCRATCH/MITgcm/run/data.sal
  # from '/nobackup/ojahn/forcing/sal/llc90/llc90_to_GL84x48XC0NS_conservative' 
  # to '/project/rrg-peltier-ac/momenika/sal/llc90/llc90_to_GL84x48XC0NS_conservative'

  #IMPORTANT 2:
  #Change KERNELS_TO_LOAD in $SCRATCH/MITgcm/run/meta_kernel
  # from /nobackup/dmenemen/forcing/SPICE/*
  # to /project/rrg-peltier-ac/momenika/SPICE/*
  #This should be done one by one for all kernels.

  salloc --nodes 1 --time 24:00:00
  cd $SCRATCH/MITgcm/run
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 113 ./mitgcmuv
