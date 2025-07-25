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
  ../../llc_hires/trillium/llc_1080/code/linux_amd64_gfortran_cspice -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code ../../llc_hires/trillium/llc_1080/code-async'
  make depend
  make -j


####RUN####
  salloc --nodes 16 --time=24:00:00
  cd cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_90x90x1872
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

