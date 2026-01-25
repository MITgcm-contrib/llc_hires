# example instructions for creating blank tiles

# for very large configurations, it is possible to reduce
# the number of MPI ranks either by using multiple processes per cpu
# or by using shared MItgcm shared memory capability within each rank

# uncomment following 2 lines for multiple processes per cpu example
# RANKS=46800
# TILES=_72x72x$RANKS

# uncomment following 2 lines for MItgcm shared memory example
RANKS=23400
TILES=_72x72x2x$RANKS

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

# 2. Create a SIZE.h without blank tiles, for example,
#    llc_hires/athena/llc_4320/code/SIZE.h_$TILES
#    Note that sNx and sNy must be factors of 4320
#    and nPx = 4320*4320*13/sNx/sNy/nSx/nSy

# 3. Run a 1-time step job to get a list of the blank tiles
#    Create a jobfile, for example,
#    llc_hires/athena/llc_4320/jobfiles/llc4320_$TILES_init.sh
 cd $WORKDIR
 mkdir jobs
 cd $WORKDIR/jobs
 cp $WORKDIR/llc_hires/athena/llc_4320/jobfiles/* .
 qsub llc4320_$TILES_init.sh

# 4. Extract Empty tile list
 cd $WORKDIR/MITgcm/run
 grep Empty STDO* > Empty_$TILES.txt
 chmod +x extract_blank.sh
 ./extract_blank.sh Empty_$TILES.txt
 wc -l blank

# 5. Create new SIZE.h and data.exch2, for example,
#    llc_hires/athena/llc_4320/code-async/SIZE.h_72x72x29271
#    llc_hires/athena/llc_4320/input/data.exch2_72x72x29271
#    where 11152 = 4320*4320*13/sNx/sNy - "results of wc -l blank"
#    in SIZE.h adjust __sNx __sNy __nPx
#    and blanklist in data.exch2 comes from file "blank"

# 6. Create a jobfile for asyncio, for example,
#    llc_hires/athena/llc_4320/jobfiles/llc4320_72x72x29271_asyncio.sh
