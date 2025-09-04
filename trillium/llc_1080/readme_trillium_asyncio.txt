############# run with asyncio #############
  salloc --nodes 18 --time=24:00:00
#  salloc --nodes 19 --time=24:00:00
#  salloc --nodes 21 --time=24:00:00
#  salloc --nodes 32 --time=24:00:00
#  salloc --nodes 49 --time=24:00:00
#  salloc --nodes 90 --time=24:00:00
#  salloc --nodes 136 --time=24:00:00
#  salloc --nodes 153 --time=24:00:00
#  salloc --nodes 171 --time=24:00:00
#  salloc --nodes 208 --time=24:00:00

####BUILD####
  cd $SCRATCH
  git clone https://github.com/MITgcm-contrib/llc_hires
  git clone https://github.com/MITgcm/MITgcm
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
  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_90x54x3120 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_60x72x3510 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_60x60x4212 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_54x54x5200 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_45x40x8424 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_30x30x16848 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_24x27x23400 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_24x24x26325 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_20x24x31590 SIZE.h
#  cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_20x20x37908 SIZE.h
  ../tools/genmake2 -of \
  ../../llc_hires/trillium/llc_1080/code-async/linux_amd64_ifort+mpi_trillium -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code-async ../../llc_hires/trillium/llc_1080/code'
  make depend
  make -j 64

####RUN####
  cd $SCRATCH/MITgcm/run
  cp ../build/mitgcmuv mitgcmuv_90x54x3120
#  cp ../build/mitgcmuv mitgcmuv_60x72x3510
#  cp ../build/mitgcmuv mitgcmuv_60x60x4212
#  cp ../build/mitgcmuv mitgcmuv_54x54x5200
#  cp ../build/mitgcmuv mitgcmuv_45x40x8424
#  cp ../build/mitgcmuv mitgcmuv_30x30x16848
#  cp ../build/mitgcmuv mitgcmuv_24x27x23400
#  cp ../build/mitgcmuv mitgcmuv_24x24x26325
#  cp ../build/mitgcmuv mitgcmuv_20x24x31590
#  cp ../build/mitgcmuv mitgcmuv_20x20x37908
  ln -sf /project/rrg-peltier-ac/momenika/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/momenika/llc1080_template/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  cp ../../llc_hires/trillium/llc_1080/input/* .

  cp data_dy109 data
  cp data.seaice_dy109 data.seaice
  cp data.shelfice_dy017 data.shelfice
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 3648 ./mitgcmuv_90x54x3120
#  mpiexec -n 4032 ./mitgcmuv_60x72x3510
#  mpiexec -n 4992 ./mitgcmuv_60x60x4212
#  mpiexec -n 6144 ./mitgcmuv_54x54x5200
#  mpiexec -n 9408 ./mitgcmuv_45x40x8424
#  mpiexec -n 17280 ./mitgcmuv_30x30x16848
#  mpiexec -n 24192 ./mitgcmuv_24x27x23400
#  mpiexec -n 29376 ./mitgcmuv_24x27x23400
#  mpiexec -n 32832 ./mitgcmuv_20x24x31590
#  mpiexec -n 39936 ./mitgcmuv_20x20x37908
