# example instructions for creating blank tiles

# 1. If not already done, download MITgcm checkpoint69f
#    and MITgcm-contrib/llc_hires on athena
 ssh athfe01
 WORKDIR=/nobackup/$USER/llc_1080
 mkdir $WORKDIR
 cd $WORKDIR
 git clone https://github.com/MITgcm/MITgcm
 git clone https://github.com/MITgcm-contrib/llc_hires
 cd $WORKDIR/MITgcm
 git checkout checkpoint69f
 cd $WORKDIR/MITgcm/pkg
 ln -s ../../llc_hires/llc_90/tides_exps/pkg_tides tides

# 2. Create a SIZE.h without blank tiles, for example,
#    llc_hires/athena/llc_1080/code/SIZE.h_30x30x16848
#    Note that sNx and sNy must be factors of 1080
#    and nPx = 1080*1080*13/sNx/sNy

# 3. Run a 1-time step job to get a list of the blank tiles
#    Create a jobfile, for example,
#    llc_hires/athena/llc_1080/jobfiles/llc1080_30x30x16848_init.sh
 cd $WORKDIR
 mkdir jobs
 cd $WORKDIR/jobs
 cp $WORKDIR/llc_hires/athena/llc_1080/jobfiles/* .
 qsub llc1080_30x30x16848_init.sh

# 4. Extract Empty tile list
 cd $WORKDIR/MITgcm/run
 grep Empty STDO* > Empty_30x30x16848.txt
 chmod +x extract_blank.sh
 ./extract_blank.sh Empty_30x30x16848.txt
 wc -l blank

# 5. Create new SIZE.h and data.exch2, for example
