############# run with asyncio #############
  salloc --nodes 13 --time=24:00:00
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
  ln -s ../../llc_hires/llc_90/tides_exps/pkg_sal   sal
  cd $SCRATCH/MITgcm
  mkdir build_sal run_sal
  cd $SCRATCH/MITgcm/build_sal
  module purge
  module load StdEnv/2023 intel/2023.2.1 intelmpi/2021.9.0
  export MPI_HOME=$I_MPI_ROOT
  MOD=$SCRATCH/llc_hires/trillium/llc_1080

  cp $MOD/code-async/SIZE.h_90x54x2229 SIZE.h
#  cp $MOD/code-async/SIZE.h_60x72x3510 SIZE.h
#  cp $MOD/code-async/SIZE.h_60x60x4212 SIZE.h
#  cp $MOD/code-async/SIZE.h_54x54x5200 SIZE.h
#  cp $MOD/code-async/SIZE.h_45x40x8424 SIZE.h
#  cp $MOD/code-async/SIZE.h_30x30x16848 SIZE.h
#  cp $MOD/code-async/SIZE.h_24x27x23400 SIZE.h
#  cp $MOD/code-async/SIZE.h_24x24x26325 SIZE.h
#  cp $MOD/code-async/SIZE.h_20x24x31590 SIZE.h
#  cp $MOD/code-async/SIZE.h_20x20x37908 SIZE.h
  ../tools/genmake2 -of \
  /project/rrg-peltier-ac/momenika/linux_amd64_ifort+mpi_trillium -mpi \
  -mods "$MOD/code-sal $MOD/code-async $MOD/code"
  make depend
  make -j 64

####RUN####
  MOD=$SCRATCH/llc_hires/trillium/llc_1080
  cd $SCRATCH/MITgcm/run_sal
  cp ../build_sal/mitgcmuv mitgcmuv_90x54x2229
#  cp ../build_sal/mitgcmuv mitgcmuv_60x72x3510
#  cp ../build_sal/mitgcmuv mitgcmuv_60x60x4212
#  cp ../build_sal/mitgcmuv mitgcmuv_54x54x5200
#  cp ../build_sal/mitgcmuv mitgcmuv_45x40x8424
#  cp ../build_sal/mitgcmuv mitgcmuv_30x30x16848
#  cp ../build_sal/mitgcmuv mitgcmuv_24x27x23400
#  cp ../build_sal/mitgcmuv mitgcmuv_24x24x26325
#  cp ../build_sal/mitgcmuv mitgcmuv_20x24x31590
#  cp ../build_sal/mitgcmuv mitgcmuv_20x20x37908
  ln -sf /project/rrg-peltier-ac/momenika/era5 .
  ln -sf /project/rrg-peltier-ac/momenika/discharge/* .
  ln -sf /project/rrg-peltier-ac/momenika/llc1080_template/* .
  ln -sf /project/rrg-peltier-ac/momenika/SPICE/kernels .
  find $MOD/input/ -type f -exec cp -t . -- {} +
  cp $MOD/input-sal/* .

  cp -f data_exp01_dy000 data
  cp -f data.seaice_exp01_dy000 data.seaice
  cp -f data.kpp_exp01 data.kpp
  cp -f data.exch2_90x54x2229 data.exch2
  unset I_MPI_PMI_LIBRARY
  mpiexec -n 2496 ./mitgcmuv_90x54x2229
#  mpiexec -n 4032 ./mitgcmuv_60x72x3510
#  mpiexec -n 4992 ./mitgcmuv_60x60x4212
#  mpiexec -n 6144 ./mitgcmuv_54x54x5200
#  mpiexec -n 9408 ./mitgcmuv_45x40x8424
#  mpiexec -n 17280 ./mitgcmuv_30x30x16848
#  mpiexec -n 24192 ./mitgcmuv_24x27x23400
#  mpiexec -n 29376 ./mitgcmuv_24x27x23400
#  mpiexec -n 32832 ./mitgcmuv_20x24x31590
#  mpiexec -n 39936 ./mitgcmuv_20x20x37908
