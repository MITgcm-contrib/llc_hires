Right now some sizes need to be configured manually:

recvTask.c   lines 79-82

#define NUM_X   2304
#define NUM_Y   3744L                     // get rid of this someday
#define NUM_Z   264
#define MULTDIM  7

and

readtile_mpiio.c    lines 115-119

    facetElements1D = 2304;
    tileSizeX = 36;
    tileSizeY = 52;
    xGhosts = 4;
    yGhosts = 4;

One tile per rank is recommended, mostly for pickup input performance,
but it is not strictly necessary.

Choose dumpFreq and pChkptFreq as usual. We're not set up
to do the rolling checkpoints yet. It'll dump u,v,t, and etan now -
send me a list of other fields you want, as it is rather involved
to change them. But this should be enough to see if it works.
