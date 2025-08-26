# ECCOV4r5 set-up
#based on https://github.com/MITgcm-contrib/llc_hires/blob/master/llc_90/ecco_v4r5/readme_v4r5_68o.txt
#code base: c68y

# /net/eady.gps.caltech.edu/data1/dmenemen/Release5 folder was downloaded from ECCO Drive
# To Download, one needs to have an Earthdata account
# (Or create it at https://urs.earthdata.nasa.gov/users/new)
# For using wget, one needs an Earthdata username and WebDAV password (different from Earthdata password)
# Find it at https://ecco.jpl.nasa.gov/drive
# and https://ecco-group.org/docs/wget_download_multiple_files_and_directories.pdf for more detail
#wget -r --no-parent --user=USERNAME --ask-password https://ecco.jpl.nasa.gov/drive/files/ECCO2/LLC90/Release5

# ========
# 1. Get code

git clone https://github.com/MITgcm-contrib/llc_hires.git
git clone https://github.com/MITgcm/MITgcm.git
cd MITgcm
git checkout checkpoint68y

# ================
# 2. Build executable

mkdir build run
cd build
module load mpi/openmpi-x86_64
export MPI_INC_DIR=/usr/include/openmpi-x86_64
MOD="../../llc_hires/llc_90/ecco_v4r5"
cp $MOD/code/SIZE.h_90x45 SIZE.h
../tools/genmake2 -mo "${MOD}/code_68y ${MOD}/code" -mpi
make depend
make -j

==============
# 3. Instructions for running simulation (1992-2019 period)

cd ../run
mkdir -p diags
ln -sf ../build/mitgcmuv .
INPUTDIR='/net/eady.gps.caltech.edu/data1/dmenemen/Release5'
ln -s ${INPUTDIR}/input_bin/* .
ln -s ${INPUTDIR}/TBADJ .
cp ${MOD}/input/* .
cp data.exch2_noblank data.exch2
mpirun -np 26 ./mitgcmuv
