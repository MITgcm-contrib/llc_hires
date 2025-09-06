# downloading and checking that MITgcm runs
  ssh trillium.scinet.utoronto.ca
  cd $SCRATCH
  git clone https://github.com/MITgcm/MITgcm
  salloc --nodes 1 --time=1:00:00
  module load gcc/13.3
  module load openmpi/5.0.3
  export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3/
  cd MITgcm/verification
  ./testreport -mpi -j 64 -t lab_sea


############ Install cspice ############ 
# Go to the NAIF CSPICE download page and grab the Unix/C package:
# https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Linux_GCC_64bit/packages/cspice.tar.Z

 tar -xzf cspice.tar.Z
 cd cspice/
 csh makeall.csh

 CSPICE_ROOT=$HOME/cspice_root

 mkdir -p $CSPICE_ROOT/{include,lib,bin}
 cp include/*     $CSPICE_ROOT/include/
 cp lib/*.a       $CSPICE_ROOT/lib/
 cp exe/*         $CSPICE_ROOT/bin/

 cd lib
 ln -s cspice.a libcspice.a
 ln -s csupport.a libcsupport.a

 cd ../..
 rm -rf cspice


############# run without asyncio #############
# to save grid information and find blank tiles
  salloc --nodes 17 --time=24:00:00

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
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_90x54x3120 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code/linux_amd64_ifort+mpi_trillium \
  -mpi -mods ../../llc_hires/trillium/llc_1080/code
  make depend
  make -j 64

####RUN####
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_90x54x3120
  ln -sf /project/rrg-peltier-ac/momenika/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/momenika/llc1080_template/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_1080/input/* .
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 3120 ./mitgcmuv_90x54x3120
