# instructions for LLC1080 asyncio + tides + sal on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_1080

# Uncomment 2 of following set of lines
 RANKS=2229
 TILES=_90x54x$RANKS
#
# RANKS=11152
# TILES=_30x30x$RANKS
#
# RANKS=30051
# TILES=_18x18x$RANKS

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
 module load jahn/shtns/3.4.5_intel-2023.2.1_cray-fftw
 cd $WORKDIR/MITgcm
 mkdir build$TILES
 cd $WORKDIR/MITgcm/build$TILES
 MOD=$WORKDIR/llc_hires/athena/llc_1080
 cp $MOD/code-async/SIZE.h$TILES SIZE.h
 ../tools/genmake2 -mpi -mods "$MOD/code_sal $MOD/code-async $MOD/code" \
  -of $MOD/code_sal/linux_amd64_ifort+mpi_cray_nas_shtns_asyncio
 make depend
 make -j

# 3. Run asyncio test
 cd $WORKDIR/llc_hires/athena/llc_1080/jobfiles
 qsub llc1080$TILES\_sal.sh

# 4. After completion, collect jobfiles in run directory
 cd $WORKDIR/MITgcm/run$TILES
 cp $WORKDIR/llc_hires/athena/llc_1080/jobfiles/llc1080$TILES\_sal.sh .
 mv $WORKDIR/llc_hires/athena/llc_1080/jobfiles/llc1080$TILES\_sal.sh.* .
