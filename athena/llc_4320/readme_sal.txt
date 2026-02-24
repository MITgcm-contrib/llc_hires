# instructions for LLC4320 asyncio + tides + sal on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_4320

# Uncomment 2 of following set of lines
 RANKS=19492
 TILES=_90x90x$RANKS
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
# RANKS=116857
# TILES=_36x36x$RANKS

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
 module load jahn/shtns/3.4.5_intel-2023.2.1
 cd $WORKDIR/MITgcm
 mkdir build$TILES
 cd $WORKDIR/MITgcm/build$TILES
 MOD=$WORKDIR/llc_hires/athena/llc_4320
 cp $MOD/code-async/SIZE.h$TILES SIZE.h
 ../tools/genmake2 -mpi -mods '$MOD/code_sal $MOD/code-async $MOD/code' \
  -of $MOD/code-async/linux_amd64_ifort+mpi_cray_nas_shtns_asyncio
 make depend
 make -j

# 3. Run asyncio test
 cd $WORKDIR/llc_hires/athena/llc_4320/jobfiles
 qsub llc4320$TILES\_sal.sh

# 4. After completion, collect jobfiles in run directory
 cd $WORKDIR/MITgcm/run$TILES
 cp $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_sal.sh .
 mv $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_sal.sh.* .





##############################

From Oliver Jahn, February 22, 2026

Hi,

I've put the map here:

/nobackup/ojahn/forcing/sal/llc4320

Relevant settings are SAL_NLAT = 180 in SAL_SIZE.h and

sal_model2llFile= 'llc4320_to_GL360x180XC0NS_conservative',
sal_lon_0= 0.,

in data.sal.  You can also include the contents of GL360x180XC0NS_lats.nml in data.sal to make sure the latitudes match for the reverse map.

Cheers,
Oliver
