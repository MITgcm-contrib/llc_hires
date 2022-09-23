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
# or on pfe just links folders/files to make input_forcing input_ecco input_init
cd llc_270
ln -s /nobackup/hzhang1/forcing/era_xx input_forcing
mkdir -p input_ecco input_init XX
cd input_ecco
for i in grace insitu  nul pri_err si_IAN  ssh  sst  ts
do
        ln -sf /nobackup/hzhang1/obs/$i/* .
done
cd ../input_init
ln -sf /nobackup/hzhang1/pub/llc270_FWD/input/* .
ln -sf /nobackup/hzhang1/pub/llc270_FWD/input/19920101/* .
rm data* eedata
ln -s sigma_MDT_glob_eccollc_llc270.bin sigma_MDT_glob_eccollc.bin
ln -s sigma_iceconc_eccollc_270.bin sigma_iceconc_eccollc.bin
ln -s slaerr_gridscale_r1_llc270.err slaerr_gridscale_r1.err
ln -s slaerr_largescale_r1_ll270.err slaerr_largescale_r1.err
cd ..
touch XX/xx

# ================
# 2. Build executable
#    Prerequisite: 1. Get code
==============
cd MITgcm
mkdir build run
cd build

   module purge
   module load comp-intel mpi-hpe hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
   ../tools/genmake2 -of ../../llc_270/code_ad/linux_amd64_ifort+mpi_ice_nas \
   -mo ../../llc_270/code_ad -mpi
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

