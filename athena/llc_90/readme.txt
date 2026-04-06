# instructions for LLC90 asyncio + tides + sal on athena
# based on llc_hires/athena/llc_1080/readme_asyncio_sal.txt
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_90

# 1. If not already done, download MITgcm checkpoint69f
#    and MITgcm-contrib/llc_hires on athena
 mkdir $WORKDIR
 cd $WORKDIR
 git clone https://github.com/MITgcm/MITgcm
 git clone https://github.com/MITgcm-contrib/llc_hires
 cd $WORKDIR/MITgcm
 git checkout checkpoint69f
 cd $WORKDIR/MITgcm/pkg
 ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides
 ln -s ../../llc_hires/llc_90/tides_exps/pkg_sal   sal

# 2. If not already done, build MITgcm
 source /opt/cray/pe/modules/3.2.11.7/init/bash
 module swap PrgEnv-cray PrgEnv-intel
 module use /u/ojahn/software/modulefiles
 module load jahn/shtns/3.7.5_intel-2023.2.1
 mkdir $WORKDIR/MITgcm/build_30x30x96
 cd $WORKDIR/MITgcm/build_30x30x96
 MOD=$WORKDIR/llc_hires/athena/llc_90
 ../tools/genmake2 -mpi -mods "$MOD/code_sal $MOD/code-async $MOD/code" \
  -of $MOD/code_sal/linux_amd64_ifort+mpi_cray_nas_shtns_asyncio
 make depend
 make -j

# 3. Run asyncio test
 cd $WORKDIR/llc_hires/athena/llc_90/jobfiles
 qsub llc90_30x30x96.sh
