# instructions for LLC4320 asyncio + tides on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_4320

# Uncomment 2 of following set of lines
# RANKS=19492
# TILES=_90x90x$RANKS
#
# RANKS=29271
# TILES=_72x72x$RANKS
#
# RANKS=52771
# TILES=_54x54x$RANKS
#
# RANKS=66469
# TILES=_48x48x$RANKS
#
# RANKS=75435
# TILES=_45x45x$RANKS
#
 RANKS=116857
 TILES=_36x36x$RANKS

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

# 2. If not already done, build MITgcm
 source /opt/cray/pe/modules/3.2.11.7/init/bash
 module swap PrgEnv-cray PrgEnv-intel
 cd $WORKDIR/MITgcm
 mkdir build$TILES
 cd $WORKDIR/MITgcm/build$TILES
 MOD="$WORKDIR/llc_hires/athena/llc_4320"
 cp "$MOD/code-async/SIZE.h$TILES" SIZE.h
 ../tools/genmake2 -mpi \
  -mods "$MOD/code-async $MOD/code" \
  -of "$MOD/code-async/linux_amd64_ifort+mpi_cray_nas_tides_asyncio"
 make depend
 make -j

# 3. Run asyncio test
 cd $WORKDIR/llc_hires/athena/llc_4320/jobfiles
 qsub llc4320$TILES\_asyncio.sh

# 4. After completion, collect jobfiles in run directory
 cd $WORKDIR/MITgcm/run$TILES
 cp $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_asyncio.sh .
 mv $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_asyncio.sh.* .
