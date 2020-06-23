# ========
#
# LLC270 state estimate
# WARNING: - Before starting make you have an Earthdata account (Or create it at: https://urs.earthdata.nasa.gov/users/new)
#
# ========

# ==============
# 1. Get code
git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout checkpoint64x
cd ..
svn checkout https://github.com/MITgcm-contrib/llc_hires/trunk/llc_270
# For the following requests you need your Earthdata username and WebDAV password (different from Earthdata password)
# Find it at :https://ecco.jpl.nasa.gov/drive
wget -r -nH -np --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/Version5/Alpha/input_forcing
wget -r -nH -np --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/Version5/Alpha/input_ecco
wget -r -nH -np --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/Version5/Alpha/input_init
wget -r -nH -np --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/Version5/Alpha/XX
mv drive/files/Version5/Alpha/input_forcing llc_270/
mv drive/files/Version5/Alpha/input_ecco    llc_270/
mv drive/files/Version5/Alpha/input_init    llc_270/
mv drive/files/Version5/Alpha/XX            llc_270/
rm -r drive/

# ================
# 2. Build executable
#    Prerequisite: 1. Get code
==============
cd MITgcm
mkdir build run
cd build

   module purge
   module load comp-intel/2016.2.181 mpi-sgi/mpt.2.14r19 hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
   ../tools/genmake2 -of ../../llc_270/code_ad/linux_amd64_ifort+mpi_ice_nas \
   -mo ../../llc_270/code_ad
   make depend
   make -j 16
 
# ================
# 3. Run model
#    Prerequisite: 2. Build executable
cd ../run
mkdir diags tapes
cp ../../llc_270/input_ad/* .
ln -s ../build/mitgcmuv .
ln -s ../../llc_270/input_forcing era_xx
ln -s ../../llc_270/input_ecco/* .
ln -s ../../llc_270/input_init/* .
ln -s ../../llc_270/XX/* .
qsub job_Irun_bM3

