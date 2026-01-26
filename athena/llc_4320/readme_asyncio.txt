# instructions for testing an LLC4320 asyncio configuration

# 1. If not already done, download MITgcm checkpoint69f
#    and MITgcm-contrib/llc_hires on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_4320
 mkdir $WORKDIR
 cd $WORKDIR
 git clone https://github.com/MITgcm/MITgcm
 git clone https://github.com/MITgcm-contrib/llc_hires
 cd $WORKDIR/MITgcm
 git checkout checkpoint69f
 cd $WORKDIR/MITgcm/pkg
 ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides

# 2. Run asyncio test
 cd $WORKDIR
 mkdir jobs
 cd $WORKDIR/jobs
 cp $WORKDIR/llc_hires/athena/llc_4320/jobfiles/* .
 qsub llc4320_72x72x29271_asyncio.sh
