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

#############################
# crashed at time step 607032
# restart at time step 606960
cd ~/llc_4320/MITgcm/run_noKPPbg_newLeith
module purge
module load comp-intel/2020.4.304 mpi-hpe/mpt
mv STDOUT.00000 STDOUT.0000606960
emacs data
 viscC4Leith=3.0,
 viscC4Leithd=3.0,
 nIter0=606960,
 hydrogThetaFile='Theta.0000606960.data',
 hydrogSaltFile ='Salt.0000606960.data',
 uVelInitFile   ='U.0000606960.data',
 vVelInitFile   ='V.0000606960.data',
 pSurfInitFile  ='Eta.0000606960.data',
emacs data.seaice
      AreaFile           = 'SIarea.0000606960.data',
      HsnowFile          = 'SIhsnow.0000606960.data',
      HsaltFile          = 'SIhsalt.0000606960.data',
      HeffFile           = 'SIheff.0000606960.data',
      UiceFile           = 'SIuice.0000606960.data',
      ViceFile           = 'SIvice.0000606960.data',
mpiexec -n 5360 ./mitgcmuv_180x180x5015

# viscC4Leith=2.145,
# viscC4Leithd=2.155,
#bash-4.4$ grep advcfl_W STDOUT.00000
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0588600617976E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0038851139601E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   2.0282773317608E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.155,
# viscC4Leithd=2.155,
#bash-4.4$ tail -f STDOUT.00000 | grep advcfl_W
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0552565053826E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.0016600207601E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.9507693014401E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.16,
# viscC4Leithd=2.16,
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0516653742581E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9946953053904E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.8843212151479E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.17,
# viscC4Leithd=2.17,
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0444936401742E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9517936826514E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.7672751140216E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.2,
# viscC4Leithd=2.2,
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0230539886428E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.8301812791533E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.5188593211674E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.25,
# viscC4Leithd=2.25,
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.9876731807594E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.6485379398441E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.2687783871408E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN
# viscC4Leith=2.5,
# viscC4Leithd=2.5,
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.3077607911890E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   8.8222701711757E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.0800694048277E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   9.9077281980357E-01
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =   1.3993990249223E+00
#(PID.TID 0000.0001) %MON advcfl_W_hf_max              =                   NaN

