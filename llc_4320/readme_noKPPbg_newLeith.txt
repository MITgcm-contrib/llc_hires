#run_template/ and forcing/ECMWF_operational/
#are also available at ECCO Drive
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC4320/run_template
# https://ecco.jpl.nasa.gov/drive/files/ECCO2/atmos/ECMWF_operational
#To access to ECCO Drive, a free NASA Earthdata login is required
#from https://urs.earthdata.nasa.gov/users/new

#############################
# 180x180x5015 configuration with Joe Skitka's Leith
# modifications and most up to date MITgcm + asyncio
cd ~/llc_4320
git clone git@github.com:MITgcm/MITgcm.git
git clone git@github.com:MITgcm-contrib/llc_hires.git
cd MITgcm
mkdir build run_noKPPbg_newLeith
module purge
module load comp-intel/2020.4.304 mpi-hpe/mpt
cd ~/llc_4320/MITgcm/build
rm *
cp ../../llc_hires/llc_4320/code-async/SIZE.h_180x180x5015 SIZE.h
cp ../../llc_hires/llc_4320/code/mom_vi_del2uv.F_jms mom_vi_del2uv.F
cp ../../llc_hires/llc_4320/code/mom_vi_hdissip.F_jms mom_vi_hdissip.F
../tools/genmake2 -of \
 ../../llc_hires/llc_4320/code-async/linux_amd64_ifort+mpi_ice_nas -mpi -mods \
 '../../llc_hires/llc_4320/code ../../llc_hires/llc_4320/code-async'
make depend
make -j
cp mitgcmuv ../run_noKPPbg_newLeith/mitgcmuv_180x180x5015

# Extract March 1, 2012 initial conditions
# ts = dte2ts('01-Mar-2012',25,2011,9,10)
# ts = 597888
cd ~/llc_4320/MITgcm/run_noKPPbg_newLeith
~/llc_4320/extract/uncompress4320 597888 Eta,Salt,Theta,U,V
~/llc_4320/extract/uncompress4320 597888 SIarea,SIheff,SIhsalt,SIhsnow,SIuice,SIvice

ln -sf /nobackup/dmenemen/tarballs/llc_4320/run_template/* .
ln -sf /nobackup/dmenemen/forcing/ECMWF_operational/* .
cp ../../llc_hires/llc_4320/input/* .
cp data_noKPPbg data
cp data.seaice_noKPPbg data.seaice
cp data.exch2_180x180x5015 data.exch2
mpiexec -n 5360 ./mitgcmuv_180x180x5015

cd ~/llc_4320/MITgcm/run_noKPPbg_newLeith
tail -f STDOUT.00000 | grep advcfl_W
