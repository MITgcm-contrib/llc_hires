# ========
#
# LLC270 adjoint sensiitivity
#
# ========

# ==============
# 1. Get code
git clone https://github.com/MITgcm-contrib/llc_hires.git
git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout checkpoint66l

# ================
# 2. Build executable
#    Prerequisite: 1. Get code
==============
cd MITgcm
mkdir build run
cd build

   module purge
   module load comp-intel mpi-hpe hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
   opt="linux_amd64_ifort+mpi_ice_nas"
   cp ../tools/build_options/$opt .
   sed -i 's|#FFLAGS="$FFLAGS -mcmodel=medium|FFLAGS="$FFLAGS -mcmodel=medium|' $opt
   sed -i 's|#CFLAGS="$CFLAGS -mcmodel=medium|CFLAGS="$CFLAGS -mcmodel=medium|' $opt
   ../tools/genmake2 -of $opt -mo ../../llc_hires/llc_270/code_sens -mpi
   make depend
   make -j16 adall
 
# ================
# 3. Run model
#    Prerequisite: 2. Build executable
cd ../run
mkdir diags tapes
ln -sf ../build/mitgcmuv_ad .
ln -sf /nobackupp19/dmenemen/public/llc_270/iter42/input/* .
ln -sf /nobackup/hzhang1/forcing/era_xx_it42_v2 .
cp ../../llc_hires/llc270/input_sens/* .
qsub job_lc270_sens

