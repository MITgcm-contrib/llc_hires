# ECCOV4r5 set-up
#based on version 2 @https://github.com/MITgcm-contrib/ecco_darwin/blob/master/v05/1deg/readme_v4r5.txt
#code base: c68o

# ========
# 1. Get code
git clone https://github.com/MITgcm-contrib/llc_hires.git
git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout checkpoint68o

# ================
# 2. Build executable
# Prerequisite: 1. Get code
mkdir build run
cd build
rm *
module load comp-intel/2020.4.304 mpi-hpe/mpt.2.25 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
MOD="../../llc_hires/llc_90/ecco_v4r5"
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
		  -mo ${MOD}/code -mpi
make depend
make -j 16

==============
# 3. Instructions for running simulation (1992-2019 period)

cd ../run
rm -rf *
mkdir -p diags
ln -sf ../build/mitgcmuv .

INPUTDIR='/nobackup/hzhang1/pub/Release5'

ln -s ${INPUTDIR}/input_bin/* .
ln -s ${INPUTDIR}/TBADJ .
cp ${MOD}/input/* .

qsub job_v4r5
