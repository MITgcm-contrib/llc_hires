############# initialization

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
cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_72x72x2925 SIZE.h
# cp ../../llc_hires/trillium/llc_1080/code/SIZE.h_108x108x1300 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/trillium/llc_1080/code/linux_amd64_ifort+mpi_ice_nas \
 -mpi -mods ../../llc_hires/trillium/llc_1080/code
make depend
make -j

cd ~/llc1080/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_72x72x2925
#cp ../build/mitgcmuv mitgcmuv_108x108x1300
ln -sf /swbuild/kzhang/llc1080/run_template/* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp ../../llc_hires/trillium/llc_1080/input/* .
mpiexec -n 2925 ./mitgcmuv_72x72x2925
# mpiexec -n 1300 ./mitgcmuv_108x108x1300

cd ~/llc1080/MITgcm/run
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
cp ../../llc_hires/trillium/llc_1080/code-async/SIZE.h_72x72x2925 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/trillium/llc_1080/code-async/linux_amd64_ifort+mpi_ice_nas -mpi \
  -mods '../../llc_hires/trillium/llc_1080/code-async ../../llc_hires/trillium/llc_1080/code'
make depend
make -j

cd ~/llc1080/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_72x72x2925
ln -sf /nobackup/kzhang/llc1080/run_template/* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/runoff1p2472-360x180x12.bin .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp ../../llc_hires/trillium/llc_1080/input/* .
mpiexec -n 3024 ./mitgcmuv_72x72x2925

#############


data
 &PARM01
 viscAr= 1e-6,  (the molecular viscosity value)

# aiming for z*
 select_rStar=2,
 nonlinFreeSurf=4,

provide shelficeloadanomaly

#define SEAICE_CAP_ICELOAD” in SEAICE_OPTIONS.h
but modified to be based on depth at that location
instead of surface level thickness

# - KPP with "Riinfty=3.5"
