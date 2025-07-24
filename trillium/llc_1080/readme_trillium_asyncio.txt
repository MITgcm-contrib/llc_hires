# downloading and checking that MITgcm runs
  ssh trillium.scinet.utoronto.ca
  ssh tri-login01
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


############# run with asyncio #############
####BUILD####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  cd $SCRATCH/MITgcm
  git checkout checkpoint69f
  cd pkg
  ln -s $SCRATCH/llc_hires/llc_90/tides_exps/pkg_tides tides
  ssh tri-login01
  salloc --nodes 16 --time=24:00:00
  # module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 netcdf-fortran-mpi/4.6.1
  module load gcc/13.3
  module load openmpi/5.0.3
  export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3/
  mkdir build run

  cd build
  module purge
  #module load StdEnv/2023  gcc/12.3  openmpi/4.1.5 netcdf-fortran-mpi/4.6.1
  module load gcc/13.3
  module load openmpi/5.0.3
  # cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_72x72x2925 SIZE.h
  cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_108x108x1300 SIZE.h

  export MPI_HOME=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v4/Compiler/gcc13/openmpi/5.0.3/
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code/linux_amd64_gfortran_cspice \
  -mpi -mods ../../llc_hires/trillium/llc_1080/code
  
  make depend
  make -j


####RUN####
  cd ../run
  #cp ../build/mitgcmuv mitgcmuv_72x72x2925
  cp ../build/mitgcmuv mitgcmuv_108x108x1300

  ln -sf /scratch/dmenemen/era5 .
  ln -sf /scratch/dmenemen/llc1080_template/* .
  ln -sf /scratch/dmenemen/SPICE/kernels .
  cp -rf  --remove-destination ../../llc_hires/trillium/llc_1080/input/* .


  # mv data.exch2_72x72x2925 data.exch2 			#No need to use this for now

  # mpiexec -n 2925 ./mitgcmuv_72x72x2925
  mpiexec -n 1300 ./mitgcmuv_108x108x1300

  tail -f STDOUT.0000 | grep advcfl_W




############# with asyncio

cd ~/llc1080
git clone https://github.com/MITgcm-contrib/llc_hires
git clone https://github.com/MITgcm/MITgcm
cd ~/llc1080/MITgcm
git checkout checkpoint69f
cd ~/llc1080/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
cd ~/llc1080/MITgcm
mkdir build run

cd ~/llc1080/MITgcm/build
module purge
module load comp-intel/2020.4.304
module load mpi-hpe/mpt.2.30
cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_216x215x325 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/trillium/llc_1080/code-async/linux_amd64_ifort+mpi_ice_nas -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code ../../llc_hires/trillium/llc_1080/code-async'
make depend
make -j

cd ~/llc1080/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_216x215x325
ln -sf /nobackup/kzhang/llc1080/run_template/* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp ../../llc_hires/trillium/llc_1080/input/* .
mv data_asyncio data
mpiexec -n 400 ./mitgcmuv_216x215x325

cd ~/llc1080/MITgcm/run
tail -f STDOUT.0000 | grep advcfl_W

