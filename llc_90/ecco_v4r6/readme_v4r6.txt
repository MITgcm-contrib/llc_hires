# ECCOV4r6 set-up
#based on https://github.com/ECCO-GROUP/ECCO-v4-Configurations/blob/master/ECCOv4%20Release%206/doc/v4r6_reproduction_instructions_total_forcing_NAS.doc
#code base: c69s

# "Release6/" folder is also available at ECCO Drive
# To Download, one needs to have an Earthdata account
# (Or create it at https://urs.earthdata.nasa.gov/users/new)
# For using wget, one needs an Earthdata username and WebDAV password (different from Earthdata password)
# Find it at https://ecco.jpl.nasa.gov/drive
# and https://ecco-group.org/docs/wget_download_multiple_files_and_directories.pdf for more detail
#wget -r --no-parent --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC90/Release6

# ========
# 1. Get code
git clone https://github.com/MITgcm-contrib/llc_hires.git
git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout checkpoint69s

# ================
# 2. Build executable
# Prerequisite: 1. Get code
mkdir build run
cd build
rm *
module load comp-intel mpi-hpe hdf4 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
MOD="../../llc_hires/llc_90/ecco_v4r6"
../tools/genmake2 -of ../tools/build_options/linux_amd64_ifort+mpi_ice_nas \
		  -mo ${MOD}/code -mpi
make depend
make -j 16

==============
# 3. Instructions for running simulation (1992-2025 period)

cd ../run
rm -rf *
mkdir -p diags
ln -sf ../build/mitgcmuv .

INPUTDIR='/nobackup/hzhang1/pub/Release6'

ln -s ${INPUTDIR}/input_bin/* .
ln -s ${INPUTDIR}/forcing .
cp ${MOD}/input/* .

qsub job_v4r6
