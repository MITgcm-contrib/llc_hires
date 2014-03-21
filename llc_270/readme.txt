#########################
# 90x90x102 configuration

module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt.2.08r7 netcdf/4.0
cd ~/llc_270
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_270
cd MITgcm
mkdir build run
cd build
cp ../../MITgcm_contrib/llc_hires/llc_270/code/SIZE.h_90x90x102 SIZE.h
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
  -mpi -mods ../../MITgcm_contrib/llc_hires/llc_270/code
make depend
make -j 16

cd ~/llc_270/MITgcm/run
cp ../build/mitgcmuv mitgcmuv_90x90x102
ln -sf /nobackupp8/dmenemen/tarballs/llc_270/run_template/* .
ln -sf /nobackupp8/dmenemen/forcing/ncep_rgau/runoffp6615-360x180x12.bin .
ln -sf /nobackupp8/hzhang1/forcing/jra55/* .
rm data.exf
cp ../../MITgcm_contrib/llc_hires/llc_270/input/* .
ln -sf data.exch2_90x90x102 data.exch2
mpiexec -n 117 ./mitgcmuv_90x90x117

tail -f STDOUT.0000 | grep advcfl_W

vals=mitgcmhistory('STDOUT.0000','time_secondsf','advcfl_W');
plot(vals(:,1)/60/60/24,vals(:,2))
