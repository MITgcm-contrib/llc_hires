# ========
# LLC1080 tides+sal on NAS non-Athena
# ========

# 1
# download MITgcm checkpoint69f and MITgcm-contrib/llc_hires
WORKDIR=/nobackup/$USER/llc_1080
mkdir $WORKDIR
cd $WORKDIR
git clone https://github.com/MITgcm/MITgcm
git clone https://github.com/MITgcm-contrib/llc_hires
cd $WORKDIR/MITgcm
git checkout checkpoint69f
cd $WORKDIR/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
ln -s ../../llc_hires/llc_90/tides_exps/pkg_sal   sal
cd ..
mkdir build run

# 2
# build llc_1080 model configuration
module purge
module load comp-intel mpi-hpe hdf4 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt

cd $WORKDIR/MITgcm/build
MOD='../../llc_hires/athena/llc_1080'
cp $MOD/code/SIZE.h_90x54x2229 SIZE.h
../tools/genmake2 -mpi -mods "$MOD/code_sal $MOD/code" \
 -of $MOD/code_sal/linux_amd64_ifort+mpi_ice_nas
make depend
make -j

# 3
# run llc_1080 model configuration
cd $WORKDIR/MITgcm/run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/hzhang1/pub/llc1080/*.bin .
ln -sf /nobackup/ojahn/forcing/sal/llc1080/*.bin .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp $MOD/input/* .
cp $MOD/input_sal/* .
cp data.exch2_90x54x2229 data.exch2

qsub job_llc1080_sal

# ========
# LLC1080 tides+sal on NAS Athena
# ========

ssh athfe01
source /opt/cray/pe/modules/3.2.11.7/init/bash
module switch PrgEnv-cray PrgEnv-intel
module use /u/ojahn/software/modulefiles
module load jahn/shtns/3.4.5_intel-2023.2.1

# 1
# download MITgcm checkpoint69f and MITgcm-contrib/llc_hires
WORKDIR=/nobackup/$USER/llc_1080
mkdir $WORKDIR
cd $WORKDIR
git clone https://github.com/MITgcm/MITgcm
git clone https://github.com/MITgcm-contrib/llc_hires
cd $WORKDIR/MITgcm
git checkout checkpoint69f
cd $WORKDIR/MITgcm/pkg
ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
ln -s ../../llc_hires/llc_90/tides_exps/pkg_sal   sal
cd ..
mkdir build run

# 2
# build llc_1080 model configuration
cd $WORKDIR/MITgcm/build
MOD='../../llc_hires/athena/llc_1080'
cp $MOD/code/SIZE.h_90x54x2229 SIZE.h
../tools/genmake2 -mpi -mods "$MOD/code_sal $MOD/code" \
 -of $MOD/code_sal/linux_amd64_ifort+mpi_cray_nas_shtns
make depend
make -j

# 3
# run llc_1080 model configuration
cd $WORKDIR/MITgcm/run
ln -sf ../build/mitgcmuv .
ln -sf /nobackup/kzhang/llc1080/run_template/*1jan23* .
ln -sf /nobackup/kzhang/llc1080/run_template/jra55* .
ln -sf /nobackup/kzhang/llc1080/run_template/*_on_LLC1080_v13* .
ln -sf /nobackup/dmenemen/tarballs/llc_1080/run_template/tile00* .
ln -sf /nobackup/hzhang1/forcing/era5 .
ln -sf /nobackup/hzhang1/pub/llc1080/*.bin .
ln -sf /nobackup/ojahn/forcing/sal/llc1080/*.bin .
ln -sf /nobackup/dmenemen/forcing/SPICE/kernels .
cp $MOD/input/* .
cp $MOD/input_sal/* .
cp data.exch2_90x54x2229 data.exch2

qsub job_llc1080_sal_athena
