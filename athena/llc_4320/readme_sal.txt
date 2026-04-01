# instructions for LLC4320 asyncio + tides + sal on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_4320

# Uncomment 2 of following set of lines
 RANKS=19493
 TILES=_90x90x$RANKS
#
# RANKS=30069
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
 module load jahn/shtns/3.7.5_intel-2023.2.1
 mkdir $WORKDIR/MITgcm/build$TILES
 cd $WORKDIR/MITgcm/build$TILES
 MOD=$WORKDIR/llc_hires/athena/llc_4320
 cp $MOD/code-async/SIZE.h$TILES SIZE.h
 ../tools/genmake2 -mpi -mods "$MOD/code_sal $MOD/code-async $MOD/code" \
  -of $MOD/code_sal/linux_amd64_ifort+mpi_cray_nas_shtns_asyncio
 make depend
 make -j

# 3. Run asyncio test
 cd $WORKDIR/llc_hires/athena/llc_4320/jobfiles
 qsub llc4320$TILES\_sal.sh

# 4. Monitoring the job
 cd $WORKDIR/MITgcm/run$TILES
 tail -f STDOUT.00000 | grep advcfl_W

# 5. Looking at system diagnostics
 qstat -u $USER
 qstat -f "Job ID" | grep comment
 ssh x1001c0s1b0n0
 cd /PBS/spool/
 free -h

# 6. Check for OOMs
# Run /u/hsp/bin/showq -n -u $USER (add -x if the job ended already)
# Then copy and paste the nodelist to a pdsh command as shown below. It'll
# list out the last OOM on each node, so just look at the date to see if it
# was during your job. We are working to fix the automated OOM notifications
# but for now it's a manual process, e.g.,
 pdsh -w x1000c2s1b0n[0-2],x1000c2s[0,6-7]b0n[0-3],x1000c1s4b0n[0-1,3],x1000c1s[0-3,5-7]b0n[0-3],x1000c[4,6-7]s[0-7]b0n[0-3],x1001c1s[0-7]b0n[0-3],x1001c6s7b0n[0-3],x1002c4s1b0n[0-1,3],x1002c4s[0,2-7]b0n[0-3],x1002c[3,5-7]s[0-7]b0n[0-3],x1002c2s[4-7]b0n[0-3],x1002c2s3b0n[1-3],x1003c3s4b0n0,x1003c3s[0-3]b0n[0-3],x1003c[0-2]s[0-7]b0n[0-3] 'dmesg -T | grep -i oom | tail -1'

# 7. After completion, collect jobfiles in run directory
 cd $WORKDIR/MITgcm/run$TILES
 cp $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_sal.sh .
 mv $WORKDIR/llc_hires/athena/llc_4320/jobfiles/llc4320$TILES\_sal.sh.* .
