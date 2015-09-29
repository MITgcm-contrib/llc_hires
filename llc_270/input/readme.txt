#########################
# 30x30x767 pure forward configuration

#model:
module purge
module load comp-intel/2012.0.032 mpi-sgi/mpt netcdf/4.0
cvs co MITgcm_code
cvs co MITgcm_contrib/llc_hires/llc_270

#compile:
cd MITgcm
mkdir build run
cd build
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
  -mpi -mods ../../MITgcm_contrib/llc_hires/llc_270/code
make depend
make -j 16

#run:
cd ../run
mkdir -p diags profiles
cp ../build/mitgcmuv .
ln -sf /nobackup/hzhang1/llc_1080/MITgcm/DM_270/era_xx .
ln -sf /nobackup/hzhang1/llc_1080/MITgcm/DM_270/input_fields/* .
cp ../../MITgcm_contrib/llc_hires/llc_270/input/* .
qsub job_767_I

#watch:
tail -f STDOUT.0000 | grep advcfl_W

vals=mitgcmhistory('STDOUT.0000','time_secondsf','advcfl_W');
plot(vals)
