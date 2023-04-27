# v05 1deg Darwin3 simulation based on ECCOV4r4 set-up
https://www.ecco-group.org/products-ECCO-V4r4.htm
https://ecco-group.org/docs/v4r4_reproduction_howto.pdf
#code base: c66g

# ========
# 1. Get code
git clone --branch backport-c66g https://github.com/jahn/darwin3
git clone --depth 1 https://github.com/MITgcm-contrib/ecco_darwin.git
cd darwin3

# ================
# 2. Build executable
# Prerequisite: 1. Get code
mkdir build run
cd build
rm *
module load comp-intel/2020.4.304 mpi-hpe/mpt.2.25 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
MOD="../../ecco_darwin/v05/1deg"
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
		  -mo ${MOD}/code_v4r4 -mpi
make depend
make -j 16

==============
# 3. Instructions for running simulation (1992-2017 period)

cd ../run
rm -rf *
mkdir -p diags
ln -sf ../build/mitgcmuv .

INPUTDIR='/nobackup/hzhang1/pub/Release4'

ln -s ${INPUTDIR}/input_bin/* .
ln -s ${INPUTDIR}/input_forcing/* .
cp ${MOD}/input_v4r4/* .

qsub job_v4r4
