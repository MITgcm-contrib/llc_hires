#run_template/ and forcing/ECMWF_operational/
#are also available at ECCO Drive
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC4320/run_template
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/atmos/ECMWF_operational
#To access to ECCO Drive, a free NASA Earthdata login is required
#from https://urs.earthdata.nasa.gov/users/new


#############################
# 180x180x5015 configuration using github and comp-intel/2020.4.304
# with no KPP background diffusivity and viscosity
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
git checkout checkpoint65v
mkdir build run_noKPPbg
module purge
module load comp-intel/2020.4.304 mpi-hpe/mpt
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code/SIZE.h_180x180x5015 SIZE.h
cp ../../llc_hires/llc_4320/code-async/readtile_mpiio.c .
emacs readtile_mpiio.c
    tileSizeX = 180;
    tileSizeY = 180;
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_noKPPbg/mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_noKPPbg
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../llc_hires/llc_4320/input/* .
cp data_noKPPbg data
ln -sf /nobackup/dmenemen/llc/llc_4320/MITgcm/run/pickup_0000485568.data pickup.0000485568.data
ln -sf /nobackup/dmenemen/llc/llc_4320/MITgcm/run/pickup_0000485568.meta pickup.0000485568.meta
ln -sf /nobackup/dmenemen/llc/llc_4320/MITgcm/run/pickup_seaice_0000485568.data pickup_seaice.0000485568.data
ln -sf /nobackup/dmenemen/llc/llc_4320/MITgcm/run/pickup_seaice_0000485568.meta pickup_seaice.0000485568.meta
cp data.exch2_180x180x5015 data.exch2
mpiexec -n 5360 ./mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_noKPPbg
tail -f STDOUT.00000 | grep advcfl_W
