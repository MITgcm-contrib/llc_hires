#run_template/ and forcing/ECMWF_operational/
#are also available at ECCO Drive
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC4320/run_template
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/atmos/ECMWF_operational
#To access to ECCO Drive, a free NASA Earthdata login is required
#from https://urs.earthdata.nasa.gov/users/new

# This configuration is identical to run_KPPghat
# except that in regions deeper than 50 m and where the ocean floor
# is deeper than 500 m, Leith only acts on 10% of the divergent flow

#############################
# 180x180x5015 configuration
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_KPPghat_noLeithDiv
module purge
module load comp-intel mpi-hpe
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_180x180x5015 SIZE.h
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas_rom -mpi \
  -mods '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_KPPghat_noLeithDiv/mitgcmuv_180x180x5015

# Extract March 1, 2012 initial conditions
# ts = dte2ts('01-Mar-2012',25,2011,9,10)
# ts = 597888
cd ~/llc_4320/MITgcm/run_KPPghat_noLeithDiv
ln -sf ../run_noKPPbg_newLeith/0000597888_* .
ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp ../../llc_hires/llc_4320/input/* .
cp data_noKPPbg_noLeithDiv data
cp data.seaice_noKPPbg data.seaice
cp data.exch2_180x180x5015 data.exch2
mpiexec -n 5632 ./mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_KPPghat_noLeithDiv
tail -f STDOUT.00000 | grep advcfl_W
