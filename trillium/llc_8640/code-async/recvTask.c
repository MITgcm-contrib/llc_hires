
// Code to do the m-on-n fan-in, recompositing, and output, of data
// tiles for MITgcm.
//
// There are aspects of this code that would be simpler in C++, but
// we deliberately wrote the code in ansi-C to make linking it with
// the Fortran main code easier (should be able to just include the
// .o on the link line).


#include "PACKAGES_CONFIG.h"
#include "SIZE.h"

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <assert.h>

#include <mpi.h>
#include <alloca.h>


#include <stdint.h>
#include <limits.h>
#include <errno.h>

#define DEBUG 1

#if (DEBUG >= 3)
#define FPRINTF fprintf
#else
#include <stdarg.h>
void FPRINTF(FILE *fp,...){return;}
#endif


#if (DEBUG >= 2)
// Define our own version of "assert", where we sleep rather than abort.
// This makes it easier to attach the debugger.
#define ASSERT(_expr)  \
    if (!(_expr))  { \
        fprintf(stderr, "ASSERT failed for pid %d : `%s': %s: %d: %s\n", \
               getpid(), #_expr, __FILE__, __LINE__, __func__); \
        sleep(9999); \
    }
#else
// Use the standard version of "assert"
#define ASSERT assert
#endif


// The hostname that each rank is running on.  Currently, only rank 0
// uses this.  It is allocated and deallocated in routine "f1"
char (*allHostnames)[HOST_NAME_MAX+1]  = NULL;


// If numRanksPerNode is set to be > 0, we just use that setting.
// If it is <= 0, we dynamically determine the number of cores on
// a node, and use that.  (N.B.: we assume *all* nodes being used in
// the run have the *same* number of MPI processes on each.)
int numRanksPerNode = 0;

// Just an error check; can be zero (if you're confident it's all correct).
#define  numCheckBits  2
// This bitMask definition works for 2's complement
#define  bitMask  ((1 << numCheckBits) - 1)


///////////////////////////////////////////////////////////////////////
// Fundamental info about the data fields.  Most (but not all) of
// this is copied or derived from the values in "SIZE.h"

// double for now.  Might also be float someday
#define datumType  double
#define datumSize  (sizeof(datumType))


// Info about the data fields.  We assume that all the fields have the
// same X and Y characteristics, but may have either 1 or NUM_Z levels.
//   bcn: or MULTDIM levels (evidently used by "sea ice").

// N.B. Please leave the seemingly unneeded "(long int)" casts in
// place.  These individual values may not need them, but they get
// used in calculations where the extra length might be important.
#define NUM_X   ((long int) sFacet)
#define NUM_Y   (((long int) sFacet) * 13)
#define NUM_Z   ((long int) Nr)
#define MULTDIM ((long int) 7)

// Some values derived from the above constants
#define twoDFieldSizeInBytes  (NUM_X * NUM_Y * 1 * datumSize)
#define threeDFieldSizeInBytes  (twoDFieldSizeInBytes * NUM_Z)
#define multDFieldSizeInBytes  (twoDFieldSizeInBytes * MULTDIM)

// Info about the data tiles.  We assume that all the tiles are the same
// size (no odd-sized last piece), they all have the same X and Y
// characteristics (including ghosting), and are full depth in Z
// (either 1, or NUM_Z, or MULTDIM, as appropriate).
#define TILE_X  sNx
#define TILE_Y  sNy
#define XGHOSTS OLx
#define YGHOSTS OLy
#define TOTAL_NUM_TILES  ((sFacet / sNx) * (sFacet / sNy) * 13)
#define NUM_WET_TILES  (nPx * nPy)

// Size of one Z level of an individual tile.  This is the "in memory"
// size, including ghosting.
#define tileOneZLevelItemCount  (((long)(TILE_X + 2*XGHOSTS)) * (TILE_Y + 2*YGHOSTS))
#define tileOneZLevelSizeInBytes  (tileOneZLevelItemCount * datumSize)



//////////////////////////////////////////////////////////////////////
// Define the depth (i.e. number of Z-levels) of the various fields.

typedef struct dataFieldDepth {
    char dataFieldID;
    int numZ;
} dataFieldDepth_t;

dataFieldDepth_t fieldDepths[] = {
   { 'A', MULTDIM },    // seaice, 7 == MULTDIM in SEAICE_SIZE.h

   { 'B', 1 },
   { 'C', 1 },
   { 'D', 1 },
   { 'E', 1 },
   { 'F', 1 },
   { 'G', 1 },
   { 'H', 1 },
   { 'I', 1 },
   { 'J', 1 },
   { 'K', 1 },
   { 'L', 1 },
   { 'M', 1 },
   { 'N', 1 },
   { 'O', 1 },
   { 'P', 1 },
   { 'Q', 1 },
   { 'R', 1 },

   { 'S', NUM_Z },
   { 'T', NUM_Z },
   { 'U', NUM_Z },
   { 'V', NUM_Z },
   { 'W', NUM_Z },
   { 'X', NUM_Z },
   { 'Y', NUM_Z },
};
#define numAllFields  (sizeof(fieldDepths)/sizeof(dataFieldDepth_t))


///////////////////////////////////////////////////////////////////////
// Info about the various kinds of i/o epochs
typedef struct epochFieldInfo {
    char dataFieldID;
    MPI_Comm registrationIntercomm;
    MPI_Comm dataIntercomm;
    MPI_Comm ioRanksIntracomm;  // i/o ranks for *this* field
    long int tileCount;
    int zDepth;  // duplicates the fieldDepth entry; filled in automatically
    int *chunkWriters;  // Which rank writes the i'th chunk of z-levels
    int nChunks;  // length of chunkWriters array
    char filenameTemplate[128];
    long int offset;
    int pickup;
} fieldInfoThisEpoch_t;

// The normal i/o dump - style 0
fieldInfoThisEpoch_t fieldsForEpochStyle_0[] = {
  { 'U', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "U.%010d.%s", 0, 0 },
  { 'V', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "V.%010d.%s", 0, 0 },
  { 'W', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "W.%010d.%s", 0, 0 },
  { 'S', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "Salt.%010d.%s", 0, 0 },
  { 'T', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "Theta.%010d.%s", 0,0 },
  { 'N', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "Eta.%010d.%s", 0,0 },

  { 'B', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIarea.%010d.%s", 0,0 },
  { 'C', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIheff.%010d.%s", 0,0 },
  { 'D', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIhsnow.%010d.%s", 0,0 },
  { 'E', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIuice.%010d.%s", 0,0 },
  { 'F', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIvice.%010d.%s", 0,0 },
  { 'G', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "SIhsalt.%010d.%s", 0,0 },

//{ 'H', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "EtaHnm1.%010d.%s", 0,0 },
  { 'I', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceTAUX.%010d.%s", 0,0 },
  { 'J', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceTAUY.%010d.%s", 0,0 },
  { 'K', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "KPPhbl.%010d.%s", 0,0 },
  { 'L', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceSflux.%010d.%s", 0,0 },

  { 'M', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceFWflx.%010d.%s", 0,0 },
  { 'O', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceQnet.%010d.%s", 0,0 },
  { 'P', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "PhiBot.%010d.%s", 0,0 },
  { 'Q', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "oceQsw.%010d.%s", 0,0 },
//{ 'R', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "dEtaHdt.%010d.%s", 0,0 },

  {'\0', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "", 0,0 },
};


// pickup file dump - style 1
// NOTE: if this changes, write_pickup_meta will also need to be changed
fieldInfoThisEpoch_t fieldsForEpochStyle_1[] = {
  { 'U', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 0 + twoDFieldSizeInBytes * 0, 1},
  { 'V', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 0, 1},
  { 'T', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 2 + twoDFieldSizeInBytes * 0, 1},
  { 'S', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 3 + twoDFieldSizeInBytes * 0, 1},
  { 'X', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 4 + twoDFieldSizeInBytes * 0, 1},
  { 'Y', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 5 + twoDFieldSizeInBytes * 0, 1},
  { 'N', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 6 + twoDFieldSizeInBytes * 0, 1},
  { 'R', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 6 + twoDFieldSizeInBytes * 1, 1},
  { 'H', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_%010d.%s", threeDFieldSizeInBytes * 6 + twoDFieldSizeInBytes * 2, 1},
  {'\0', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "", 0 ,1},
};


// seaice pickup dump - style 2
// NOTE: if this changes, write_pickup_meta will also need to be changed
fieldInfoThisEpoch_t fieldsForEpochStyle_2[] = {
  { 'A', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 0 + twoDFieldSizeInBytes * 0, 2},
  { 'B', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 0, 2},
  { 'C', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 1, 2},
  { 'D', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 2, 2},
  { 'G', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 3, 2},
  { 'E', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 4, 2},
  { 'F', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "pickup_seaice_%010d.%s", multDFieldSizeInBytes * 1 + twoDFieldSizeInBytes * 5, 2},
  {'\0', MPI_COMM_NULL, MPI_COMM_NULL, MPI_COMM_NULL, 0, -1, NULL, 0, "", 0 },
};


fieldInfoThisEpoch_t *epochStyles[] = {
    fieldsForEpochStyle_0,
    fieldsForEpochStyle_1,
    fieldsForEpochStyle_2,
};
int numEpochStyles = (sizeof(epochStyles) / sizeof(fieldInfoThisEpoch_t *));


typedef enum {
    cmd_illegal,
    cmd_newEpoch,
    cmd_epochComplete,
    cmd_exit,
} epochCmd_t;


///////////////////////////////////////////////////////////////////////

// Note that a rank will only have access to one of the Intracomms,
// but all ranks will define the Intercomm.
MPI_Comm ioIntracomm = MPI_COMM_NULL;
int ioIntracommRank = -1;
MPI_Comm computeIntracomm = MPI_COMM_NULL;
int computeIntracommRank = -1;
MPI_Comm globalIntercomm = MPI_COMM_NULL;


#define divCeil(_x,_y)  (((_x) + ((_y) - 1)) / (_y))
#define roundUp(_x,_y)  (divCeil((_x),(_y)) * (_y))


typedef enum {
    bufState_illegal,
    bufState_Free,
    bufState_InUse,
} bufState_t;


typedef struct buf_header{
    struct buf_header *next;
    bufState_t state;
    int requestsArraySize;
    MPI_Request *requests;
    char *payload;
} bufHdr_t;


bufHdr_t *freeTileBufs_ptr = NULL;
bufHdr_t *inUseTileBufs_ptr = NULL;

int maxTagValue = -1;


// routine to convert double to float during memcpy
// need to get byteswapping in here as well
memcpy_r8_2_r4 (float *f, double *d, long long *n)
{
long long i, rem;
	rem = *n%16LL;
	for (i = 0; i < rem; i++) {
		f [i] = d [i];
	}
	for (i = rem; i < *n; i += 16) {
		__asm__ __volatile__ ("prefetcht0	%0	# memcpy_r8_2_r4.c 10" :  : "m" (d [i + 256 + 0]) );
		__asm__ __volatile__ ("prefetcht0	%0	# memcpy_r8_2_r4.c 11" :  : "m" (f [i + 256 + 0]) );
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm0	# memcpy_r8_2_r4.c 12" :  : "m" (d [i + 0]) : "%xmm0");
		__asm__ __volatile__ ("movss	%%xmm0, %0	# memcpy_r8_2_r4.c 13" : "=m" (f [i + 0]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm1	# memcpy_r8_2_r4.c 14" :  : "m" (d [i + 1]) : "%xmm1");
		__asm__ __volatile__ ("movss	%%xmm1, %0	# memcpy_r8_2_r4.c 15" : "=m" (f [i + 1]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm2	# memcpy_r8_2_r4.c 16" :  : "m" (d [i + 2]) : "%xmm2");
		__asm__ __volatile__ ("movss	%%xmm2, %0	# memcpy_r8_2_r4.c 17" : "=m" (f [i + 2]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm3	# memcpy_r8_2_r4.c 18" :  : "m" (d [i + 3]) : "%xmm3");
		__asm__ __volatile__ ("movss	%%xmm3, %0	# memcpy_r8_2_r4.c 19" : "=m" (f [i + 3]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm4	# memcpy_r8_2_r4.c 20" :  : "m" (d [i + 4]) : "%xmm4");
		__asm__ __volatile__ ("movss	%%xmm4, %0	# memcpy_r8_2_r4.c 21" : "=m" (f [i + 4]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm5	# memcpy_r8_2_r4.c 22" :  : "m" (d [i + 5]) : "%xmm5");
		__asm__ __volatile__ ("movss	%%xmm5, %0	# memcpy_r8_2_r4.c 23" : "=m" (f [i + 5]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm6	# memcpy_r8_2_r4.c 24" :  : "m" (d [i + 6]) : "%xmm6");
		__asm__ __volatile__ ("movss	%%xmm6, %0	# memcpy_r8_2_r4.c 25" : "=m" (f [i + 6]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm7	# memcpy_r8_2_r4.c 26" :  : "m" (d [i + 7]) : "%xmm7");
		__asm__ __volatile__ ("prefetcht0	%0	# memcpy_r8_2_r4.c 27" :  : "m" (d [i + 256 + 8 + 0]) );
		__asm__ __volatile__ ("movss	%%xmm7, %0	# memcpy_r8_2_r4.c 28" : "=m" (f [i + 7]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm8	# memcpy_r8_2_r4.c 29" :  : "m" (d [i + 8]) : "%xmm8");
		__asm__ __volatile__ ("movss	%%xmm8, %0	# memcpy_r8_2_r4.c 30" : "=m" (f [i + 8]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm9	# memcpy_r8_2_r4.c 31" :  : "m" (d [i + 9]) : "%xmm9");
		__asm__ __volatile__ ("movss	%%xmm9, %0	# memcpy_r8_2_r4.c 32" : "=m" (f [i + 9]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm10	# memcpy_r8_2_r4.c 33" :  : "m" (d [i + 10]) : "%xmm10");
		__asm__ __volatile__ ("movss	%%xmm10, %0	# memcpy_r8_2_r4.c 34" : "=m" (f [i + 10]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm11	# memcpy_r8_2_r4.c 35" :  : "m" (d [i + 11]) : "%xmm11");
		__asm__ __volatile__ ("movss	%%xmm11, %0	# memcpy_r8_2_r4.c 36" : "=m" (f [i + 11]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm12	# memcpy_r8_2_r4.c 37" :  : "m" (d [i + 12]) : "%xmm12");
		__asm__ __volatile__ ("movss	%%xmm12, %0	# memcpy_r8_2_r4.c 38" : "=m" (f [i + 12]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm13	# memcpy_r8_2_r4.c 39" :  : "m" (d [i + 13]) : "%xmm13");
		__asm__ __volatile__ ("movss	%%xmm13, %0	# memcpy_r8_2_r4.c 40" : "=m" (f [i + 13]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm14	# memcpy_r8_2_r4.c 41" :  : "m" (d [i + 14]) : "%xmm14");
		__asm__ __volatile__ ("movss	%%xmm14, %0	# memcpy_r8_2_r4.c 42" : "=m" (f [i + 14]) :  : "memory");
		__asm__ __volatile__ ("cvtsd2ss	%0, %%xmm15	# memcpy_r8_2_r4.c 43" :  : "m" (d [i + 15]) : "%xmm15");
		__asm__ __volatile__ ("movss	%%xmm15, %0	# memcpy_r8_2_r4.c 44" : "=m" (f [i + 15]) :  : "memory");
	}
}


// Debug routine
countBufs(int nbufs)
{
    int nInUse, nFree;
    bufHdr_t *bufPtr;
    static int target = -1;

    if (-1 == target) {
        ASSERT(-1 != nbufs);
        target = nbufs;
    }

    bufPtr = freeTileBufs_ptr;
    for (nFree = 0;  bufPtr != NULL;  bufPtr = bufPtr->next) nFree += 1;

    bufPtr = inUseTileBufs_ptr;
    for (nInUse = 0;  bufPtr != NULL;  bufPtr = bufPtr->next) nInUse += 1;

    if (nInUse + nFree != target) {
        fprintf(stderr, "Rank %d: bad number of buffs: free %d, inUse %d, should be %d\n",
                        ioIntracommRank, nFree, nInUse, target);
    }
    ASSERT ((nInUse + nFree) == target);
}


long int readn(int fd, void *p, long int nbytes)
{

  char *ptr = (char*)(p);

    long int nleft, nread;
  
    nleft = nbytes;
    while (nleft > 0){
	nread = read(fd, ptr, nleft);
	if (nread < 0)
	    return(nread); // error
	else if (nread == 0)
	    break;  // EOF
    
	nleft -= nread;
	ptr += nread;
    }
    return (nbytes - nleft);
}


ssize_t writen(int fd, void *p, size_t nbytes)
{
  char *ptr = (char*)(p);

  size_t nleft;
  ssize_t nwritten;

    nleft = nbytes;
    while (nleft > 0){
	nwritten = write(fd, ptr, nleft);
	if (nwritten <= 0){
	  if (errno==EINTR) continue; // POSIX, not SVr4
	  return(nwritten);           // non-EINTR error 
	}

	nleft -= nwritten;
	ptr += nwritten;
    }
    return(nbytes - nleft);
}


void write_pickup_meta(FILE *fp, int gcmIter, int pickup)
{
  int i;
  int ndims = 2;
  int nrecords,nfields;
  char**f;
  char*fld1[] = {"Uvel","Vvel","Theta","Salt","GuNm1","GvNm1","EtaN","dEtaHdt","EtaH"};
  char*fld2[] = {"siTICES","siAREA","siHEFF","siHSNOW","siHSALT","siUICE","siVICE"};
  // for now, just list the fields here. When the whole field specification apparatus
  // is cleaned up, pull the names out of the epochstyle definition or whatever

  ASSERT(1==pickup||2==pickup);

  if (1==pickup){
    nrecords = 6*NUM_Z+3;
    nfields = sizeof(fld1)/sizeof(char*);
    f = fld1;
  }
  else if (2==pickup){
    nrecords = MULTDIM+6;
    nfields = sizeof(fld2)/sizeof(char*);
    f = fld2;
  }
  
  fprintf(fp," nDims = [ %3d ];\n",ndims);
  fprintf(fp," dimList = [\n");
  fprintf(fp," %10lu,%10d,%10lu,\n",NUM_X,1,NUM_X);
  fprintf(fp," %10ld,%10d,%10ld\n",NUM_Y,1,NUM_Y);
  fprintf(fp," ];\n");
  fprintf(fp," dataprec = [ 'float64' ];\n");
  fprintf(fp," nrecords = [ %5d ];\n",nrecords);
  fprintf(fp," timeStepNumber = [ %10d ];\n",gcmIter);
  fprintf(fp," timeInterval = [ %19.12E ];\n",0.0);     // what should this be?
  fprintf(fp," nFlds = [ %4d ];\n",nfields);
  fprintf(fp," fldList = {\n");
  for (i=0;i<nfields;++i)
    fprintf(fp," '%-8s'",f[i]);
  fprintf(fp,"\n };\n");
}



double *outBuf=NULL;//was [NUM_X*NUM_Y*NUM_Z], but only needs to be myNumZSlabs
size_t outBufSize=0;


void
do_write(int io_epoch, fieldInfoThisEpoch_t *whichField, int myFirstZ, int myNumZ, int gcmIter)
{
  if (0==myNumZ) return;

  int pickup = whichField->pickup;

  ///////////////////////////////
  // swap here, if necessary
  //  int i,j;

  //i = NUM_X*NUM_Y*myNumZ;
  //mds_byteswapr8_(&i,outBuf);

  // mds_byteswapr8 expects an integer count, which is gonna overflow someday
  // can't redefine to long without affecting a bunch of other calls
  // so do a slab at a time here, to delay the inevitable
  //  i = NUM_X*NUM_Y;
  //for (j=0;j<myNumZ;++j)
  //  mds_byteswapr8_(&i,&outBuf[i*j]);

  // gnu builtin evidently honored by intel compilers
  
  if (pickup) {
    uint64_t *alias = (uint64_t*)outBuf;
    size_t i;
    for (i=0;i<NUM_X*NUM_Y*myNumZ;++i)
      alias[i] = __builtin_bswap64(alias[i]);
  }
  else {
    uint32_t *alias = (uint32_t*)outBuf;
    size_t i;
    for (i=0;i<NUM_X*NUM_Y*myNumZ;++i)
      alias[i] = __builtin_bswap32(alias[i]);
  }

  // end of swappiness
  //////////////////////////////////

  char s[1024];
  //sprintf(s,"henze_%d_%d_%c.dat",io_epoch,gcmIter,whichField->dataFieldID);

  sprintf(s,whichField->filenameTemplate,gcmIter,"data");

  int fd = open(s,O_CREAT|O_WRONLY,S_IRWXU|S_IRGRP);
  ASSERT(fd!=-1);

  size_t nbytes;

  if (pickup) {
    lseek(fd,whichField->offset,SEEK_SET);
    lseek(fd,myFirstZ*NUM_X*NUM_Y*datumSize,SEEK_CUR);
    nbytes = NUM_X*NUM_Y*myNumZ*datumSize;
  }
  else {
    lseek(fd,myFirstZ*NUM_X*NUM_Y*sizeof(float),SEEK_CUR);
    nbytes = NUM_X*NUM_Y*myNumZ*sizeof(float);
  }

  ssize_t bwrit = writen(fd,outBuf,nbytes);  

  if (-1==bwrit) perror("Henze : file write problem : ");

  FPRINTF(stderr,"Wrote %d of %d bytes (%d -> %d) \n",bwrit,nbytes,myFirstZ,myNumZ);

  //  ASSERT(nbytes == bwrit);

  if (nbytes!=bwrit)
    fprintf(stderr,"WROTE %ld /%ld\n",bwrit,nbytes);

  close(fd);


  return;
}



typedef struct {
  long int off;
  long int skip;
} tile_layout_t;

tile_layout_t *offsetTable;

void
processSlabSection(
  fieldInfoThisEpoch_t *whichField,
  int tileID,
  void *data,
  int myNumZSlabs)
{
  int z;

  int pickup = whichField->pickup;

  ASSERT ((tileID > 0) && (tileID <= TOTAL_NUM_TILES));

  if (myNumZSlabs * twoDFieldSizeInBytes > outBufSize){

    free(outBuf);

    outBufSize = myNumZSlabs * twoDFieldSizeInBytes;

    outBuf = malloc(outBufSize);
    ASSERT(outBuf);

    memset(outBuf,0,outBufSize);
  }

  for (z=0;z<myNumZSlabs;++z){

    off_t zoffset = z*TILE_X*TILE_Y*TOTAL_NUM_TILES;
    off_t hoffset = offsetTable[tileID].off;
    off_t skipdst = offsetTable[tileID].skip;

    //double *dst = outBuf + zoffset + hoffset;
    void *dst;
    if (pickup)
      dst = outBuf + zoffset + hoffset;
    else
      dst = (float*)outBuf + zoffset + hoffset;

    off_t zoff = z*(TILE_X+2*XGHOSTS)*(TILE_Y+2*YGHOSTS);
    off_t hoff = YGHOSTS*(TILE_X+2*XGHOSTS) + YGHOSTS;
    double *src = (double*)data + zoff + hoff;

    off_t skipsrc = TILE_X+2*XGHOSTS;

    long long n = TILE_X;

    int y;
    if (pickup)
      for (y=0;y<TILE_Y;++y)
	memcpy((double*)dst + y * skipdst, src + y * skipsrc, TILE_X*datumSize);
    else
      for (y=0;y<TILE_Y;++y)
	memcpy_r8_2_r4((float*)dst + y * skipdst, src + y * skipsrc, &n);
  }

  return;
}



// Allocate some buffers to receive tile-data from the compute ranks
void
allocateTileBufs(int numTileBufs, int maxIntracommSize)
{
    int i, j;
    for (i = 0;  i < numTileBufs;  ++i) {

        bufHdr_t *newBuf = malloc(sizeof(bufHdr_t));
        ASSERT(NULL != newBuf);

	newBuf->payload = malloc(tileOneZLevelSizeInBytes * NUM_Z);
	ASSERT(NULL != newBuf->payload);

        newBuf->requests =  malloc(maxIntracommSize * sizeof(MPI_Request));
        ASSERT(NULL != newBuf->requests);

        // Init some values
	newBuf->requestsArraySize = maxIntracommSize;
        for (j = 0;  j < maxIntracommSize;  ++j) {
            newBuf->requests[j] = MPI_REQUEST_NULL;
        }

        // Put the buf into the free list
        newBuf->state = bufState_Free;
        newBuf->next = freeTileBufs_ptr;
        freeTileBufs_ptr = newBuf;
    }
}



bufHdr_t *
getFreeBuf()
{
    int j;
    bufHdr_t *rtnValue = freeTileBufs_ptr;

    if (NULL != rtnValue) {
        ASSERT(bufState_Free == rtnValue->state);
        freeTileBufs_ptr = rtnValue->next;
        rtnValue->next = NULL;

        // Paranoia.  This should already be the case
        for (j = 0;  j < rtnValue->requestsArraySize;  ++j) {
            rtnValue->requests[j] = MPI_REQUEST_NULL;
        }
    }
    return rtnValue;
}


/////////////////////////////////////////////////////////////////


bufHdr_t *
tryToReceiveDataTile(
  MPI_Comm dataIntercomm,
  int epochID,
  size_t expectedMsgSize,
  int *tileID)
{
    bufHdr_t *bufHdr;
    int pending, i, count;
    MPI_Status mpiStatus;

    MPI_Iprobe(MPI_ANY_SOURCE, MPI_ANY_TAG, dataIntercomm,
               &pending, &mpiStatus);

    // If no data are pending, or if we can't get a buffer to
    // put the pending data into, return NULL
    if (!pending) return NULL;
    if (((bufHdr = getFreeBuf()) == NULL)) {
        FPRINTF(stderr,"tile %d(%d) pending, but no buf to recv it\n",
                mpiStatus.MPI_TAG, mpiStatus.MPI_TAG >> numCheckBits);
        return NULL;
    }

    // Do sanity checks on the pending message
    MPI_Get_count(&mpiStatus, MPI_BYTE, &count);
    ASSERT(count == expectedMsgSize);
    ASSERT((mpiStatus.MPI_TAG & bitMask) == (epochID & bitMask));

    // Recieve the data we saw in the iprobe
    MPI_Recv(bufHdr->payload, expectedMsgSize, MPI_BYTE,
             mpiStatus.MPI_SOURCE, mpiStatus.MPI_TAG,
             dataIntercomm, &mpiStatus);
    bufHdr->state = bufState_InUse;

    // Return values
    *tileID = mpiStatus.MPI_TAG >> numCheckBits;


    FPRINTF(stderr, "recv tile %d(%d) from compute rank %d\n",
            mpiStatus.MPI_TAG, *tileID, mpiStatus.MPI_SOURCE);

    return bufHdr;
}



int
tryToReceiveZSlab(
  void *buf,
  long int expectedMsgSize,
  MPI_Comm intracomm)
{
    MPI_Status mpiStatus;
    int pending, count;

    MPI_Iprobe(MPI_ANY_SOURCE, MPI_ANY_TAG, intracomm, &pending, &mpiStatus);
    if (!pending) return -1;

    MPI_Get_count(&mpiStatus, MPI_BYTE, &count);
    ASSERT(count == expectedMsgSize);

    MPI_Recv(buf, count, MPI_BYTE, mpiStatus.MPI_SOURCE,
             mpiStatus.MPI_TAG, intracomm, &mpiStatus);

    FPRINTF(stderr, "recv slab %d from rank %d\n",
             mpiStatus.MPI_TAG, mpiStatus.MPI_SOURCE);

    // return the tileID
    return mpiStatus.MPI_TAG;
}


void
redistributeZSlabs(
  bufHdr_t *bufHdr,
  int tileID,
  int zSlabsPer,
  fieldInfoThisEpoch_t *fieldInfo)
{
    int thisFieldNumZ = fieldInfo->zDepth;
    long int tileSizeInBytes = tileOneZLevelSizeInBytes * thisFieldNumZ;
    long int fullPieceSize = zSlabsPer * tileOneZLevelSizeInBytes;
    long int offset = 0;

    MPI_Comm intracomm = fieldInfo->ioRanksIntracomm;

    // Note that the MPI interface definition requires that this arg
    // (i.e. "pieceSize") be of type "int".  So check to be sure we
    // haven't overflowed the size.
    int pieceSize = (int)fullPieceSize;
    if (pieceSize != fullPieceSize) {
        fprintf(stderr, "ERROR: pieceSize:%d, fullPieceSize:%ld\n",
                        pieceSize,    fullPieceSize);
        fprintf(stderr, "ERROR: tileOneZLevelSizeInBytes:%ld, tileSizeInBytes:%ld\n",
                        tileOneZLevelSizeInBytes,     tileSizeInBytes);
        fprintf(stderr, "ERROR: thisFieldNumZ:%d, zSlabsPer:%d\n",
                          thisFieldNumZ    , zSlabsPer);
    }
    ASSERT (pieceSize == fullPieceSize);
    ASSERT (pieceSize > 0);


    // Send each piece (aka chunk) to the rank that is responsible
    // for writing it.
    int curPiece = 0;
    while ((offset + pieceSize) <= tileSizeInBytes) {
        int recvRank = fieldInfo->chunkWriters[curPiece];
        MPI_Isend(bufHdr->payload + offset, pieceSize, MPI_BYTE, recvRank,
                  tileID, intracomm, &(bufHdr->requests[recvRank]));
        ASSERT(MPI_REQUEST_NULL != bufHdr->requests[recvRank]);

        offset += pieceSize;
        curPiece += 1;
    }

    // There might be one last odd-sized piece (N.B.: odd-sized in Z;
    // the X and Y sizes of a tile are always the same).
    if (offset < tileSizeInBytes) {
        ASSERT (pieceSize >= tileSizeInBytes - offset);
        pieceSize = tileSizeInBytes - offset;
        ASSERT(pieceSize % tileOneZLevelSizeInBytes == 0);

        int recvRank = fieldInfo->chunkWriters[curPiece];
        MPI_Isend(bufHdr->payload + offset, pieceSize, MPI_BYTE, recvRank,
                  tileID, intracomm, &(bufHdr->requests[recvRank]));
        ASSERT(MPI_REQUEST_NULL != bufHdr->requests[recvRank]);
        curPiece += 1;
    }

    ASSERT (curPiece == fieldInfo->nChunks);
}



/////////////////////////////////////////////////////////////////
// This is called by the i/o ranks
void
doNewEpoch(int epochID, int epochStyleIndex, int gcmIter)
{
    // In an i/o epoch, the i/o ranks are partitioned into groups,
    // each group dealing with one field.  The ranks within a group:
    // (1) receive data tiles from the compute ranks
    // (2) slice the received data tiles into slabs in the 'z'
    //     dimension, and redistribute the tile-slabs among the group.
    // (3) receive redistributed tile-slabs, and reconstruct a complete
    //     field-slab for the whole field.
    // (4) Write the completed field-slab to disk.

    fieldInfoThisEpoch_t *fieldInfo;
    int intracommRank, intracommSize;

    int zSlabsPer;
    int myNumZSlabs, myFirstZSlab, myLastZSlab, myNumSlabPiecesToRecv;

    int ii, numTilesRecvd, numSlabPiecesRecvd;


    // Find the descriptor for my assigned field for this epoch style.
    // It is the one whose dataIntercomm is not null
    fieldInfo = epochStyles[epochStyleIndex];
    while (MPI_COMM_NULL == fieldInfo->dataIntercomm) ++fieldInfo;
    ASSERT('\0' != fieldInfo->dataFieldID);


    MPI_Comm_rank(fieldInfo->ioRanksIntracomm, &intracommRank);
    MPI_Comm_size(fieldInfo->ioRanksIntracomm, &intracommSize);

    zSlabsPer = divCeil(fieldInfo->zDepth, intracommSize);

    // Figure out if this rank writes z-slabs, and if so, which ones
    myNumZSlabs = 0;
    myFirstZSlab = 0;
    myLastZSlab = -1;
    for (ii = 0;  ii < fieldInfo->nChunks;  ++ii) {
        if (fieldInfo->chunkWriters[ii] == intracommRank) {
            myFirstZSlab = ii * zSlabsPer;
            // The last chunk might be odd sized
            myNumZSlabs = ((ii + 1) < fieldInfo->nChunks) ?
                               zSlabsPer : fieldInfo->zDepth - myFirstZSlab;
            myLastZSlab = myFirstZSlab + myNumZSlabs - 1;

            break;
        }
    }
    if (myNumZSlabs > 0) {
        ASSERT ((myFirstZSlab >= 0) && (myFirstZSlab < fieldInfo->zDepth));
        ASSERT ((myLastZSlab >= 0) && (myLastZSlab < fieldInfo->zDepth));
        ASSERT (myLastZSlab >= myFirstZSlab);
    }


    // If we were not assigned any z-slabs, we don't get any redistributed
    // tile-slabs.  If we were assigned one or more slabs, we get
    // redistributed tile-slabs for every tile.
    myNumSlabPiecesToRecv = (0 == myNumZSlabs) ? 0 : NUM_WET_TILES;


    numTilesRecvd = 0;
    numSlabPiecesRecvd = 0;

    ////////////////////////////////////////////////////////////////////
    // Main loop.  Handle tiles from the current epoch
    for(;;) {
        bufHdr_t *bufHdr;

        ////////////////////////////////////////////////////////////////
        // Check for tiles from the computational tasks
        while (numTilesRecvd < fieldInfo->tileCount) {
            int tileID = -1;
            size_t msgSize = tileOneZLevelSizeInBytes * fieldInfo->zDepth;
            bufHdr = tryToReceiveDataTile(fieldInfo->dataIntercomm, epochID,
                                          msgSize, &tileID);
            if (NULL == bufHdr) break; // No tile was received

            numTilesRecvd += 1;
            redistributeZSlabs(bufHdr, tileID, zSlabsPer, fieldInfo);

            // Add the bufHdr to the "in use" list
            bufHdr->next = inUseTileBufs_ptr;
            inUseTileBufs_ptr = bufHdr;
        }


        ////////////////////////////////////////////////////////////////
        // Check for tile-slabs redistributed from the i/o processes
        while (numSlabPiecesRecvd < myNumSlabPiecesToRecv) {
            long int msgSize = tileOneZLevelSizeInBytes * myNumZSlabs;
            char data[msgSize];

            int tileID = tryToReceiveZSlab(data, msgSize, fieldInfo->ioRanksIntracomm);
            if (tileID < 0) break;  // No slab was received

            numSlabPiecesRecvd += 1;
	    processSlabSection(fieldInfo, tileID, data, myNumZSlabs);

            // Can do the write here, or at the end of the epoch.
            // Probably want to make it asynchronous (waiting for
            // completion at the barrier at the start of the next epoch).
            //if (numSlabPiecesRecvd >= myNumSlabPiecesToRecv) {
            //    ASSERT(numSlabPiecesRecvd == myNumSlabPiecesToRecv);
            //    do_write(io_epoch,whichField,myFirstZSlab,myNumZSlabs);
            //}
        }


        ////////////////////////////////////////////////////////////////
	// Sanity check for non-writers
	if (0 == myNumSlabPiecesToRecv) {  

	    long int msgSize = tileOneZLevelSizeInBytes * myNumZSlabs;
	    char data[msgSize];

            // Check that no one has tried to re-distribute a slab to us.
            int tileID = tryToReceiveZSlab(data, msgSize, fieldInfo->ioRanksIntracomm);
            ASSERT (tileID < 0);
	}


        ////////////////////////////////////////////////////////////////
        // Check if we can release any of the inUse buffers (i.e. the
        // isends we used to redistribute those z-slabs have completed).
        // We do this by detaching the inUse list, then examining each
        // element in the list, putting each element either into the
        // free list or back into the inUse list, as appropriate.
        bufHdr = inUseTileBufs_ptr;
        inUseTileBufs_ptr = NULL;
        while (NULL != bufHdr) {
            int count = 0;
            int completions[intracommSize];
            MPI_Status statuses[intracommSize];

            // Acquire the "next" bufHdr now, before we change anything.
            bufHdr_t *nextBufHeader = bufHdr->next;

            // Check to see if the Isend requests have completed for this buf
            MPI_Testsome(intracommSize, bufHdr->requests,
                         &count, completions, statuses);

            if (MPI_UNDEFINED == count) {
                // A return of UNDEFINED means that none of the requests
                // is still outstanding, i.e. they have all completed.
                // Put the buf on the free list.
                bufHdr->state = bufState_Free;
                bufHdr->next = freeTileBufs_ptr;
                freeTileBufs_ptr = bufHdr;
                FPRINTF(stderr,"Rank %d freed a tile buffer\n", intracommRank);
            } else {
                // At least one request is still outstanding.
                // Put the buf back on the inUse list.
                bufHdr->next = inUseTileBufs_ptr;
                inUseTileBufs_ptr = bufHdr;
            }

            // Countinue with the next buffer
            bufHdr = nextBufHeader;
        }


        ////////////////////////////////////////////////////////////////
        // Check if the epoch is complete
        if ((numTilesRecvd >= fieldInfo->tileCount)  &&
            (numSlabPiecesRecvd >= myNumSlabPiecesToRecv) &&
            (NULL == inUseTileBufs_ptr))
        {
            ASSERT(numTilesRecvd == fieldInfo->tileCount);
            ASSERT(numSlabPiecesRecvd == myNumSlabPiecesToRecv);

	    //fprintf(stderr,"rank %d %d %d %d\n",intracommRank,numTilesRecvd,numSlabPiecesRecvd,myNumZSlabs);

            // Ok, wrap up the current i/o epoch
            // Probably want to make this asynchronous (waiting for
            // completion at the start of the next epoch).
            do_write(epochID, fieldInfo, myFirstZSlab, myNumZSlabs, gcmIter);

            // The epoch is complete
            return;
        }
    }

}




// Main routine for the i/o tasks.  Callers DO NOT RETURN from
// this routine; they MPI_Finalize and exit.
void
ioRankMain (void)
{
    // This is one of a group of i/o processes that will be receiving tiles
    // from the computational processes.  This same process is also
    // responsible for compositing slices of tiles together into one or
    // more complete slabs, and then writing those slabs out to disk.
    //
    // When a tile is received, it is cut up into slices, and each slice is
    // sent to the appropriate compositing task that is dealing with those
    // "z" level(s) (possibly including ourselves).  These are tagged with
    // the tile-id.  When we *receive* such a message (from ourselves, or
    // from any other process in this group), we unpack the data (stripping
    // the ghost cells), and put them into the slab we are assembling.  Once
    // a slab is fully assembled, it is written to disk.

    int i, ierr, count, numTileBufs;
    MPI_Status status;
    int currentEpochID = 0;
    int maxTileCount = 0, max3DTileCount = 0, maxIntracommSize = 0;

    int numComputeRanks, epochStyleIndex;
    MPI_Comm_remote_size(globalIntercomm, &numComputeRanks);


    int *xoff = malloc(TOTAL_NUM_TILES*sizeof(int));
    ASSERT(xoff);
    int *yoff = malloc(TOTAL_NUM_TILES*sizeof(int));
    ASSERT(yoff);
    int *xskip = malloc(TOTAL_NUM_TILES*sizeof(int));
    ASSERT(xskip);

    offsetTable = malloc((TOTAL_NUM_TILES+1)*sizeof(tile_layout_t));
    ASSERT(offsetTable);

    ierr = MPI_Bcast(xoff,TOTAL_NUM_TILES,MPI_INT,0,globalIntercomm);
    ierr = MPI_Bcast(yoff,TOTAL_NUM_TILES,MPI_INT,0,globalIntercomm);
    ierr = MPI_Bcast(xskip,TOTAL_NUM_TILES,MPI_INT,0,globalIntercomm);

    for (i=0;i<TOTAL_NUM_TILES;++i){
      offsetTable[i+1].off = NUM_X*(yoff[i]-1) + xoff[i] - 1;
      offsetTable[i+1].skip = xskip[i];
    }

    free(xoff);
    free(yoff);
    free(xskip);

    ///////////////////////////////////////////////////////////////


    // At this point, the multitude of various inter-communicators have
    // been created and stored in the various epoch "style" arrays.
    // The next step is to have the computational tasks "register" the
    // data tiles they will send.  In this version of the code, we only
    // track and store *counts*, not the actual tileIDs.
    for (epochStyleIndex = 0;  epochStyleIndex < numEpochStyles;  ++epochStyleIndex) {
        fieldInfoThisEpoch_t *p = NULL;
        fieldInfoThisEpoch_t *thisEpochStyle = epochStyles[epochStyleIndex];
        int thisIntracommSize;

        // Find the field we were assigned for this epoch style
        int curFieldIndex = -1;
        while ('\0' != thisEpochStyle[++curFieldIndex].dataFieldID) {
            p = &(thisEpochStyle[curFieldIndex]);
            if (MPI_COMM_NULL != p->registrationIntercomm) break;
        }
        ASSERT(NULL != p);
        ASSERT('\0' != p->dataFieldID);
        MPI_Comm_size(p->ioRanksIntracomm, &thisIntracommSize);
        if (thisIntracommSize > maxIntracommSize) {
            maxIntracommSize = thisIntracommSize;
        }


        // Receive a message from *each* computational rank telling us
        // a count of how many tiles that rank will send during epochs
        // of this style.  Note that some of these counts may be zero
        for (i = 0;  i < numComputeRanks;  ++i) {
            MPI_Recv(NULL, 0, MPI_BYTE, MPI_ANY_SOURCE, MPI_ANY_TAG,
                     p->registrationIntercomm, &status);
            p->tileCount += status.MPI_TAG;
        }
        if (p->tileCount > maxTileCount) maxTileCount = p->tileCount;
        if (p->zDepth > 1) {
            if (p->tileCount > max3DTileCount) max3DTileCount = p->tileCount;
        }

        // Sanity check
        MPI_Allreduce (&(p->tileCount), &count, 1,
                       MPI_INT, MPI_SUM, p->ioRanksIntracomm);
        ASSERT(count == NUM_WET_TILES);
    }


    // In some as-of-yet-undetermined fashion, we decide how many
    // buffers to allocate to hold tiles received from the computational
    // tasks.  The number of such buffers is more-or-less arbitrary (the
    // code should be able to function with any number greater than zero).
    // More buffers means more parallelism, but uses more space.
    // Note that maxTileCount is an upper bound on the number of buffers
    // that we can usefully use.  Note also that if we are assigned a 2D
    // field, we might be assigned to recieve a very large number of tiles
    // for that field in that epoch style.

    // Hack - for now, just pick a value for numTileBufs
    numTileBufs = (max3DTileCount > 0) ? max3DTileCount : maxTileCount;
    if (numTileBufs < 4) numTileBufs = 4;
    if (numTileBufs > 25) numTileBufs = 25;

    allocateTileBufs(numTileBufs, maxIntracommSize);
    countBufs(numTileBufs);


    ////////////////////////////////////////////////////////////////////
    // Main loop.
    ////////////////////////////////////////////////////////////////////

    for (;;) {
        int cmd[4];

        // Make sure all the i/o ranks have completed processing the prior
        // cmd (i.e. the prior i/o epoch is complete).
        MPI_Barrier(ioIntracomm);

        if (0 == ioIntracommRank) {
	    fprintf(stderr, "I/O ranks waiting for new epoch at time %f\n",MPI_Wtime());
	    MPI_Send(NULL, 0, MPI_BYTE, 0, cmd_epochComplete, globalIntercomm);

            MPI_Recv(cmd, 4, MPI_INT, 0, 0, globalIntercomm, MPI_STATUS_IGNORE);
            fprintf(stderr, "I/O ranks begining new epoch: %d, gcmIter = %d, at time %f\n",
                            cmd[1], cmd[3], MPI_Wtime());

	    // before we start a new epoch, have i/o rank 0:
	    // determine output filenames for this epoch
	    // clean up any extant files with same names 
	    // write .meta files

	    if (cmd_exit != cmd[0]){

	      fprintf(stderr,"new epoch: epoch %d, style %d, gcmIter %d\n", cmd[1],cmd[2],cmd[3]);

	      int epochStyle = cmd[2];
	      int gcmIter = cmd[3];
	    
	      fieldInfoThisEpoch_t *fieldInfo;
	      fieldInfo = epochStyles[epochStyle];
	      char s[1024];
	      int res;
	      FILE *fp;

	      if (fieldInfo->pickup==0){    // for non-pickups, need to loop over individual fields
		char f;
		while (f = fieldInfo->dataFieldID){
		  sprintf(s,fieldInfo->filenameTemplate,gcmIter,"data");
		  fprintf(stderr,"%s\n",s);
		  res = unlink(s);
		  if (-1==res && ENOENT!=errno) fprintf(stderr,"unable to rm %s\n",s);
		  
		  // skip writing meta files for non-pickup fields
		  /*
		  sprintf(s,fieldInfo->filenameTemplate,gcmIter,"meta");
		  fp = fopen(s,"w+");
		  fclose(fp);
		  */		  

		  ++fieldInfo;

		}	      
	      }
	      
	      else {                       // single pickup or pickup_seaice file

		sprintf(s,fieldInfo->filenameTemplate,gcmIter,"data");
		fprintf(stderr,"%s\n",s);
		res = unlink(s);
		if (-1==res && ENOENT!=errno) fprintf(stderr,"unable to rm %s\n",s);

		sprintf(s,fieldInfo->filenameTemplate,gcmIter,"meta");
		fp = fopen(s,"w+");
		write_pickup_meta(fp, gcmIter, fieldInfo->pickup);
		fclose(fp);

	      }
	    }
	}
        MPI_Bcast(cmd, 4, MPI_INT, 0, ioIntracomm);  

	if (0 == ioIntracommRank)
	  fprintf(stderr,"i/o handshake completed %d %d %f\n",cmd[1],cmd[3],MPI_Wtime());

        switch (cmd[0]) {

          case cmd_exit:
            // Don't bother trying to disconnect and free the
            // plethora of communicators; just exit.
            FPRINTF(stderr,"Received shutdown message\n");
            MPI_Finalize();
            exit(0);
          break;

          case cmd_newEpoch:
            if ((currentEpochID + 1) != cmd[1]) {
                fprintf(stderr, "ERROR: Missing i/o epoch?  was %d, "
                        "but is now %d ??\n", currentEpochID, cmd[1]);
                sleep(1); // Give the message a chance to propagate
                abort();
            }
            currentEpochID = cmd[1];

	    memset(outBuf,0,outBufSize);  // zero the outBuf, so dry tiles are well defined

            doNewEpoch(cmd[1], cmd[2], cmd[3]);
          break;

          default:
            fprintf(stderr, "Unexpected epoch command: %d %d %d %d\n",
                    cmd[0], cmd[1], cmd[2], cmd[3]);
            sleep(1);
            abort();
          break;
        }

    }

}



///////////////////////////////////////////////////////////////////////////////////

int
findField(const char c)
{
    int i;
    for (i = 0; i < numAllFields;  ++i) {
        if (c == fieldDepths[i].dataFieldID)  return i;
    }

    // Give the error message a chance to propagate before exiting.
    fprintf(stderr, "ERROR: Field not found: '%c'\n", c);
    sleep(1);
    abort();
}



// Given a number of ranks and a set of fields we will want to output,
// figure out how to distribute the ranks among the fields.
// We attempt to distribute according to three separate criteria:
//  1) Try to make the number of ranks assigned to a field be
//     proportional to the number of bytes in that field.
//  2) Try to even out the total number of MPI messages that are
//     sent to any given i/o node.
//  3) Try to even out the amount of output being written from
//     any given i/o node.

void
computeIORankAssigments(
  int numComputeRanks,
  int numIORanks,
  int numFields,
  fieldInfoThisEpoch_t *fields,
  int assignments[],
  int nToWrite[])
{
    int i,j,k, iteration, sum, count;

    int numIONodes = numIORanks / numRanksPerNode;
    int numIORanksThisField[numFields], nRanks[numFields];
    long int bytesPerIORankThisField[numFields];
    int expectedMessagesPerRankThisField[numFields];
    int isWriter[numIORanks];
    long int fieldSizes[numFields];

    struct ioNodeInfo_t {
        int expectedNumMessagesThisNode;
        int numCoresAssigned;
        int *assignedFieldThisCore;
    }  ioNodeInfo[numIONodes];

    // Since numRanksPerNode might be dynamically determined, we have
    // to dynamically allocate the assignedFieldThisCore arrays.
    for (i = 0;  i < numIONodes;  ++i) {
        ioNodeInfo[i].assignedFieldThisCore = malloc(sizeof(int)*numRanksPerNode);
        ASSERT(NULL != ioNodeInfo[i].assignedFieldThisCore);
    }

    ASSERT((numIONodes*numRanksPerNode) == numIORanks);

    memset (assignments, 0, numIORanks*sizeof(int));
    memset (isWriter, 0, numIORanks*sizeof(int));


    //////////////////////////////////////////////////////////////
    // Compute the size for each field in this epoch style
    for (i = 0;  i < numFields;  ++i) {
      ASSERT((1 == fields[i].zDepth) || (NUM_Z == fields[i].zDepth) || (MULTDIM == fields[i].zDepth));
        fieldSizes[i] = twoDFieldSizeInBytes * fields[i].zDepth;
    }


    /////////////////////////////////////////////////////////////////
    // Phase 1: Distribute the number of available i/o ranks among
    // the fields, proportionally based on field size.

    // First, assign one rank per field
    ASSERT(numIORanks >= numFields);
    for (i = 0;  i < numFields;  ++i) {
        numIORanksThisField[i] = 1;
        bytesPerIORankThisField[i] = fieldSizes[i];
    }

    // Now apportion any extra ranks
    for (;  i < numIORanks;  ++i) {

        // Find the field 'k' with the most bytesPerIORank
        k = 0;
        for (j = 1;  j < numFields;  ++j) {
            if (bytesPerIORankThisField[j] > bytesPerIORankThisField[k]) {
                k = j;
            }
        }

        // Assign an i/o rank to that field
        numIORanksThisField[k] += 1;
        bytesPerIORankThisField[k] = fieldSizes[k] / numIORanksThisField[k];
    }

    /////////////////////////////////////////////////////////////////
    // At this point, the number of i/o ranks should be apportioned
    // among the fields.  Check we didn't screw up the count.
    for (sum = 0, i = 0;  i < numFields;  ++i) {
        sum += numIORanksThisField[i];
    }
    ASSERT(sum == numIORanks);

    // Make a copy of numIORanksThisField
    memcpy (nRanks, numIORanksThisField, numFields*sizeof(int));



    //////////////////////////////////////////////////////////////////
    // Phase 2: try to even out the number of messages per node.
    // The *number* of i/o ranks assigned to a field is based on the
    // field size.  But the *placement* of those ranks is based on
    // the expected number of messages the process will receive.
    // [In particular, if we have several fields each with only one
    // assigned i/o rank, we do not want to place them all on the
    // same node if we don't have to.]  This traffic-load balance
    // strategy is an approximation at best since the messages may
    // not all be the same size (e.g. 2D fields vs. 3D fields), so
    // "number of messages" is not the same thing as "traffic".
    // But it should suffice.

    // Init a couple of things
    for (i = 0;  i < numFields;  ++i) {
        expectedMessagesPerRankThisField[i] =
                numComputeRanks / numIORanksThisField[i];
    }
    for (i = 0;  i < numIONodes;  ++i) {
        ioNodeInfo[i].expectedNumMessagesThisNode = 0;
        ioNodeInfo[i].numCoresAssigned = 0;
        for (j = 0;  j < numRanksPerNode;  ++j) {
            ioNodeInfo[i].assignedFieldThisCore[j] = -1;
        }
    }

    ///////////////////////////////////////////////////////////////////
    // Select the i/o node with the smallest expectedNumMessages, and
    // assign it a rank from the field with the highest remaining
    // expectedMessagesPerRank.  Repeat until everything is assigned.
    // (Yes, this could be a lot faster, but isn't worth the trouble.)

    for (count = 0;  count < numIORanks;  ++count) {

        // Make an initial choice of node
        for (i = 0;  i < numIONodes;  ++i) {
            if (ioNodeInfo[i].numCoresAssigned < numRanksPerNode) break;
        }
        j = i;
        ASSERT(j < numIONodes);

        // Search for a better choice
        for (++i;  i < numIONodes;  ++i) {
            if (ioNodeInfo[i].numCoresAssigned >= numRanksPerNode) continue;
            if (ioNodeInfo[i].expectedNumMessagesThisNode <
                ioNodeInfo[j].expectedNumMessagesThisNode)
            {
                j = i;
            }
        }


        // Make an initial choice of field
        for (i = 0;  i < numFields;  ++i) {
            if (nRanks[i] > 0) break;
        }
        k = i;
        ASSERT(k < numFields);

        // Search for a better choice
        for (++i;  i < numFields;  ++i) {
            if (nRanks[i] <= 0) continue;
            if (expectedMessagesPerRankThisField[i] >
                expectedMessagesPerRankThisField[k])
            {
                k = i;
            }
        }

        // Put one rank from the chosen field onto the chosen node
        ioNodeInfo[j].expectedNumMessagesThisNode += expectedMessagesPerRankThisField[k];
        ioNodeInfo[j].assignedFieldThisCore[ioNodeInfo[j].numCoresAssigned] = k;
        ioNodeInfo[j].numCoresAssigned += 1;
        nRanks[k] -= 1;
    }

    // Sanity check - all ranks were assigned to a core
    for (i = 1;  i < numFields;  ++i) {
        ASSERT(0 == nRanks[i]);
    }
    // Sanity check - all cores were assigned a rank
    for (i = 1;  i < numIONodes;  ++i) {
        ASSERT(numRanksPerNode == ioNodeInfo[i].numCoresAssigned);
    }


    //////////////////////////////////////////////////////////////////
    // Phase 3: Select which ranks will be assigned to write out the
    // fields.  We attempt to balance the amount that each node is
    // assigned to write out.  Since Phase 1 and Phase 2 have already
    // fixed a number of things, our options for balancing things
    // is somewhat restricted.


    // Count how many nodes each field is distributed across
    int numIONodesThisField[numFields];
    for (i = 0;  i < numFields;  ++i) {
        numIONodesThisField[i] = 0;
        for (j = 0;  j < numIONodes;  ++j) {
            for (k = 0;  k < numRanksPerNode;  ++k) {
                if (ioNodeInfo[j].assignedFieldThisCore[k] == i) {
                    numIONodesThisField[i] += 1;
                    break;
                }
            }
        }
        ASSERT (numIONodesThisField[i] > 0);
        ASSERT (numIONodesThisField[i] <= numIONodes);
    }


    // Init a per-node running count of z-levels-to-write
    memset (nToWrite, 0, numIONodes*sizeof(int));


    // Iterate through all the fields, although we will select
    // which field to operate on (i.e. curField) non-sequentially.
    for (iteration = 0;  iteration < numFields;  ++iteration) {

        // Pick the field distributed across the fewest number of nodes, on
        // the theory that this field will have the least flexibility.
        int curField = 0;
        for (j = 1;  j < numFields;  ++j) {
            if (numIONodesThisField[j] < numIONodesThisField[curField]) {
                curField = j;
            }
        }
        ASSERT (numIONodesThisField[curField] <= numIONodes);

        // Now that we have chosen a field, identify any i/o nodes
        // that have rank(s) assigned to that field.
        int nAssigned[numIONodes];
        for (i = 0;  i < numIONodes;  ++i) {
            nAssigned[i] = 0;
            for (j = 0;  j < numRanksPerNode;  ++j) {
                if (ioNodeInfo[i].assignedFieldThisCore[j] == curField) {
                    nAssigned[i] += 1;
                }
            }
        }


        // We do the writes in units of entire z-levels.  If a rank is a
        // writer, it is assigned to write a chunk of one or more z-levels.
        int chunkSize = divCeil (fields[curField].zDepth, numIORanksThisField[curField]);
        int nChunks = divCeil (fields[curField].zDepth, chunkSize);
        int curChunk;

        // Designate the same number of ranks to be writers as there are chunks
        fields[curField].chunkWriters = malloc (nChunks*sizeof(int));
        ASSERT (fields[curField].chunkWriters != NULL);
        fields[curField].nChunks = nChunks;
        int nAvailable[numIONodes];
        memcpy (nAvailable, nAssigned, numIONodes*sizeof(int));
        for (curChunk = 0;  curChunk < nChunks;  ++curChunk) {

            // Note that the last chunk might be an odd size (if chunkSize
            // does not evenly divide zDepth).
            if ((curChunk + 1) == nChunks) {
              chunkSize = fields[curField].zDepth - curChunk*chunkSize;
            }

            // Pick a node that has at least one rank assigned to curField
            // that has not already been designated as a writer.
            // There must still be at least one, or we would have exited
            // the loop already.
            int curNode;
            for (curNode = 0;  curNode < numIONodes;  ++curNode) {
                if (nAvailable[curNode] > 0) break;
            }
            ASSERT (curNode < numIONodes);

            // curNode is a candidate node; try to find an acceptable
            // candidate node with a smaller nToWrite
            for (i = curNode + 1;  i < numIONodes;  ++i) {
                if ((nAvailable[i] > 0) && (nToWrite[i] < nToWrite[curNode])) {
                  curNode = i;
                }
            }

            // Find an appropriate rank on the chosen node
            for (j = 0;  j < numRanksPerNode;  ++j) {
                if ( (ioNodeInfo[curNode].assignedFieldThisCore[j] == curField) &&
                     (!isWriter[curNode*numRanksPerNode + j]) )
                {
                    break;
                }
            }
            // Double-check that we found an appropriate rank.
            ASSERT (j < numRanksPerNode);


            // We've picked a rank to be the writer of the current chunk.
            // Now we need to figure out which rank this will wind up being
            // in the "ioRanksIntracomm" for this field (when that intracomm
            // eventually gets created), so we can set "chunkWriters".
            int eventualCommRank = 0;
            for (i = 0;  i < curNode;  ++i) eventualCommRank += nAssigned[i];
            for (i = 0;  i < j;  ++i) {
                if (ioNodeInfo[curNode].assignedFieldThisCore[i] == curField) {
                    eventualCommRank += 1;
                }
            }


            // Update the info for this choice of node+rank
            fields[curField].chunkWriters[curChunk] = eventualCommRank;
            isWriter[curNode*numRanksPerNode + j] = 1;
            nAvailable[curNode] -= 1;
            nToWrite[curNode] += chunkSize;

        }

        // We've finished with this curField; mark it so that we don't
        // re-select this same curField the next time through the loop.
        numIONodesThisField[curField] =  numIONodes + 1;
    }


    //////////////////////////////////////////////////////////////////
    // Return the computed assignments
    // N.B. We are also returning info in "fields[*].chunkWriters"
    for (i = 0;  i < numIONodes;  ++i) {
        for (j = 0;  j < numRanksPerNode;  ++j) {
            assignments[i*numRanksPerNode + j] =
                    ioNodeInfo[i].assignedFieldThisCore[j];
        }
    }


    // Clean up
    for (i = 0;  i < numIONodes;  ++i) {
        free(ioNodeInfo[i].assignedFieldThisCore);
    }

}

//////////////////////////////////////////////////////////////////////////////////


int
isIORank(int commRank, int totalNumNodes, int numIONodes)
{
    // Figure out if this rank is on a node that will do i/o.
    // Note that the i/o nodes are distributed throughout the
    // task, not clustered together.
    int thisRankNode = commRank / numRanksPerNode;

    int ioNodeStride = totalNumNodes / numIONodes;
    int extra = totalNumNodes % numIONodes;

    int inflectionPoint = (ioNodeStride+1)*extra;
    if (thisRankNode <= inflectionPoint) {
        return (thisRankNode % (ioNodeStride+1)) == 0;
    } else {
        return ((thisRankNode - inflectionPoint) % ioNodeStride) == 0;
    }

}



// Get the number of MPI ranks that are running on one node.
// We assume that the MPI ranks are launched in sequence, filling one
// node before going to the next, and that each node has the same
// number of ranks (except possibly the last node, which is allowed
// to be short).
int
getNumRanksPerNode (MPI_Comm comm)
{
    char myHostname[HOST_NAME_MAX+1];
    int status, count;
    int commSize, commRank;

    MPI_Comm_size (comm, &commSize);
    MPI_Comm_rank (comm, &commRank);

    status = gethostname (myHostname, HOST_NAME_MAX);
    myHostname[HOST_NAME_MAX] = '\0';
    ASSERT (0 == status);

    if (0 == commRank) {
        int nBlocks, ii, jj;
        assert (allHostnames != NULL);

        // We assume these are already in-order and so don't
        // need to be sorted.

        // Count how many ranks have the same hostname as rank 0
        for (count = 0;
               (count < commSize) &&
               (strcmp(&(allHostnames[count][0]), myHostname) == 0);
             ++count);
        ASSERT (count > 0);

        // Check that the count is consistent for each block of hostnames
        // (except possibly the last block, which might not be full).
        nBlocks = commSize / count;

        for (jj = 1;  jj < nBlocks;  ++jj) {
            char *p = &(allHostnames[jj*count][0]);
            for (ii = 0;  ii < count;  ++ii) {
                char *q = &(allHostnames[jj*count + ii][0]);
                ASSERT (strcmp (p, q) == 0);
            }
        }
    }

    MPI_Bcast (&count, 1, MPI_INT, 0, comm);
    return count;
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
// Routines called by the mitGCM code


////////////////////////////////////////
// Various "one time" initializations
void
f1(
  MPI_Comm parentComm,
  int numComputeRanks,
  int numTiles,
  MPI_Comm *rtnComputeComm)
{
    // Note that we ignore the argument "numTiles".  This value used to
    // be needed, but now we get the information directly from "SIZE.h"

    MPI_Comm newIntracomm, newIntercomm, dupParentComm;
    int newIntracommRank, thisIsIORank;
    int parentSize, parentRank;
    int numIONodes, numIORanks;
    int mpiIsInitialized, *intPtr, tagUBexists;
    int i, j, nF, compRoot, fieldIndex, epochStyleIndex;
    int totalNumNodes, numComputeNodes, newIntracommSize;


    // Init globals

    // Info about the parent communicator
    MPI_Initialized(&mpiIsInitialized);
    ASSERT(mpiIsInitialized);
    MPI_Comm_size(parentComm, &parentSize);
    MPI_Comm_rank(parentComm, &parentRank);

    // Find the max MPI "tag" value
    MPI_Attr_get(MPI_COMM_WORLD, MPI_TAG_UB, &intPtr, &tagUBexists);
    ASSERT(tagUBexists);
    maxTagValue = *intPtr;

    // Gather all the hostnames to rank zero
    char myHostname[HOST_NAME_MAX+1];
    int status;
    status = gethostname (myHostname, HOST_NAME_MAX);
    myHostname[HOST_NAME_MAX] = '\0';
    ASSERT (0 == status);
    if (parentRank != 0) {
        // send my hostname to rank 0
        MPI_Gather (myHostname, HOST_NAME_MAX+1, MPI_CHAR,
                    NULL, 0, MPI_CHAR, 0, parentComm);
    }
    else {
        allHostnames = malloc (parentSize*(HOST_NAME_MAX+1));
        assert (allHostnames != NULL);

        // Collect the hostnames from all the ranks
        MPI_Gather (myHostname, HOST_NAME_MAX+1, MPI_CHAR,
                    allHostnames, HOST_NAME_MAX+1, MPI_CHAR,
                    0, parentComm);
    }

    if (numRanksPerNode <= 0) {
        // Might also want to check for an env var (or something)
        // N.B.: getNumRanksPerNode uses an MPI collective on the communicator
        // and needs the global "allHostnames" to already be set in rank 0.
        numRanksPerNode = getNumRanksPerNode(parentComm);
    }

    // Fill in the zDepth field of the fieldInfoThisEpoch_t descriptors
    for (epochStyleIndex = 0;  epochStyleIndex < numEpochStyles;  ++epochStyleIndex) {
        fieldInfoThisEpoch_t  *f, *thisEpochStyle = epochStyles[epochStyleIndex];

        int curFieldIndex = -1;
        while ((f = &(thisEpochStyle[++curFieldIndex]))->dataFieldID != '\0') {
            i = findField(f->dataFieldID);
            if (-1 != f->zDepth) {
                if (f->zDepth != fieldDepths[i].numZ) {
                    fprintf(stderr, "Inconsistent z-depth for field '%c': "
                                    "fieldDepths[%d] and epoch style %d\n",
                                     f->dataFieldID, i, epochStyleIndex);
                }
            }
            f->zDepth = fieldDepths[i].numZ;
        }
    }



    // Figure out how many nodes we can use for i/o.
    // To make things (e.g. memory calculations) simpler, we want
    // a node to have either all compute ranks, or all i/o ranks.
    // If numComputeRanks does not evenly divide numRanksPerNode, we have
    // to round up in favor of the compute side.

    totalNumNodes = divCeil(parentSize, numRanksPerNode);
    numComputeNodes = divCeil(numComputeRanks, numRanksPerNode);
    numIONodes = (parentSize - numComputeRanks) / numRanksPerNode;
    ASSERT(numIONodes > 0);
    ASSERT(numIONodes <= (totalNumNodes - numComputeNodes));
    numIORanks = numIONodes * numRanksPerNode;


    // Print out the hostnames, identifying which ones are i/o nodes

    if (0 == parentRank) {
        printf ("\n%d total nodes,  %d i/o,  %d compute\n",
                totalNumNodes, numIONodes, numComputeNodes);
        for (i = 0;  i < parentSize;  i += numRanksPerNode) {
            if (isIORank (i, totalNumNodes, numIONodes)) {
                printf ("\n(%s)", &(allHostnames[i][0]));
            } else {
                printf (" %s", &(allHostnames[i][0]));
            }
        }
        printf ("\n\n");
    }
    fflush (stdout);



    // It is surprisingly easy to launch the job with the wrong number
    // of ranks, particularly if the number of compute ranks is not a
    // multiple of numRanksPerNode (the tendency is to just launch one
    // rank per core for all available cores).  So we introduce a third
    // option for a rank: besides being an i/o rank or a compute rank,
    // it might instead be an "excess" rank, in which case it just
    // calls MPI_Finalize and exits.

    typedef enum { isCompute, isIO, isExcess } rankType;
    rankType thisRanksType;

    if (isIORank(parentRank, totalNumNodes, numIONodes)) {
        thisRanksType = isIO;
    } else if (parentRank >= numComputeRanks + numIORanks) {
        thisRanksType = isExcess;
    } else {
        thisRanksType = isCompute;
    }

    // Split the parent communicator into parts
    MPI_Comm_split(parentComm, thisRanksType, parentRank, &newIntracomm);
    MPI_Comm_rank(newIntracomm, &newIntracommRank);

    // Excess ranks disappear
    // N.B. "parentComm" (and parentSize) still includes these ranks, so
    // we cannot do MPI *collectives* using parentComm after this point,
    // although the communicator can still be used for other things.
    if (isExcess == thisRanksType) {
        MPI_Finalize();
        exit(0);
    }

    // Sanity check
    MPI_Comm_size(newIntracomm, &newIntracommSize);
    if (isIO == thisRanksType) {
        ASSERT(newIntracommSize == numIORanks);
    } else {
        ASSERT(newIntracommSize == numComputeRanks);
    }


    // Create a special intercomm from the i/o and compute parts
    if (isIO == thisRanksType) {
        // Set globals
        ioIntracomm = newIntracomm;
        MPI_Comm_rank(ioIntracomm, &ioIntracommRank);

        // Find the lowest computation rank
        for (i = 0;  i < parentSize;  ++i) {
            if (!isIORank(i, totalNumNodes, numIONodes)) break;
        }
    } else {  // isCompute
        // Set globals
        computeIntracomm = newIntracomm;
        MPI_Comm_rank(computeIntracomm, &computeIntracommRank);

        // Find the lowest IO rank
        for (i = 0;  i < parentSize;  ++i) {
            if (isIORank(i, totalNumNodes, numIONodes)) break;
        }
    }
    MPI_Intercomm_create(newIntracomm, 0, parentComm, i, 0, &globalIntercomm);



    ///////////////////////////////////////////////////////////////////
    // For each different i/o epoch style, split the i/o ranks among
    // the fields, and create an inter-communicator for each split.

    for (epochStyleIndex = 0;  epochStyleIndex < numEpochStyles;  ++epochStyleIndex) {
        if (0 == parentRank) {
            printf ("Set up epoch style %d\n", epochStyleIndex);
        }

        fieldInfoThisEpoch_t *thisEpochStyle = epochStyles[epochStyleIndex];
        int fieldAssignments[numIORanks];
        int rankAssignments[numComputeRanks + numIORanks];

        // Count the number of fields in this epoch style
        for (nF = 0;  thisEpochStyle[nF].dataFieldID != '\0';  ++nF) ;

        // Decide how to apportion the i/o ranks among the fields.
        // (Currently, this call also sets the "chunkWriters" array.)
        for (i=0; i < numIORanks; ++i) fieldAssignments[i] = -1;
        int nToWrite[numIORanks/numRanksPerNode];
        computeIORankAssigments(numComputeRanks, numIORanks, nF,
                              thisEpochStyle, fieldAssignments, nToWrite);
        // Sanity check
        for (i=0; i < numIORanks; ++i) {
            ASSERT((fieldAssignments[i] >= 0) && (fieldAssignments[i] < nF));
        }

        // Embed the i/o rank assignments into an array holding
        // the assignments for *all* the ranks (i/o and compute).
        // Rank assignment of "-1" means "compute".
        j = 0;
        for (i = 0;  i < numComputeRanks + numIORanks;  ++i) {
            rankAssignments[i] = isIORank(i, totalNumNodes, numIONodes)  ?
                                 fieldAssignments[j++]  :  -1;
        }
        // Sanity check.  Check the assignment for this rank.
        if (isIO == thisRanksType) {
            ASSERT(fieldAssignments[newIntracommRank] == rankAssignments[parentRank]);
        } else {
            ASSERT(-1 == rankAssignments[parentRank]);
        }
        ASSERT(j == numIORanks);


        if (0 == parentRank) {
            printf ("Create communicators for epoch style %d\n", epochStyleIndex);
        }
        fflush (stdout);


        // Find the lowest rank assigned to computation; use it as
        // the "root" for the upcoming intercomm creates.
        for (compRoot = 0; rankAssignments[compRoot] != -1;  ++compRoot);
        // Sanity check
        if ((isCompute == thisRanksType) && (0 == newIntracommRank)) ASSERT(compRoot == parentRank);

        // If this is an I/O rank, split the newIntracomm (which, for
        // the i/o ranks, is a communicator among all the i/o ranks)
        // into the pieces as assigned.

        if (isIO == thisRanksType) {
            MPI_Comm fieldIntracomm;
            int myField = rankAssignments[parentRank];
            ASSERT(myField >= 0);

            MPI_Comm_split(newIntracomm, myField, parentRank, &fieldIntracomm);
            thisEpochStyle[myField].ioRanksIntracomm = fieldIntracomm;

            // Now create an inter-communicator between the computational
            // ranks, and each of the newly split off field communicators.
            for (i = 0;  i < nF;  ++i) {

                // Do one field at a time to avoid clashes on parentComm
                MPI_Barrier(newIntracomm);

                if (myField != i) continue;

                // Create the intercomm for this field for this epoch style
                MPI_Intercomm_create(fieldIntracomm, 0, parentComm,
                        compRoot, i, &(thisEpochStyle[myField].dataIntercomm));

                // ... and dup a separate one for tile registrations
                MPI_Comm_dup(thisEpochStyle[myField].dataIntercomm,
                         &(thisEpochStyle[myField].registrationIntercomm));


                // Sanity check: make sure the chunkWriters array looks ok.
                {
                    int ii, jj, commSize, nChunks = thisEpochStyle[myField].nChunks;
                    ASSERT (nChunks > 0);
                    ASSERT (thisEpochStyle[myField].chunkWriters != NULL);
                    MPI_Comm_size (thisEpochStyle[myField].dataIntercomm, &commSize);
                    for (ii = 0;  ii < nChunks;  ++ii) {
                        ASSERT (thisEpochStyle[myField].chunkWriters[ii] >=  0);
                        ASSERT (thisEpochStyle[myField].chunkWriters[ii] < commSize);
                        for (jj = ii+1;  jj < nChunks;  ++jj) {
                            ASSERT (thisEpochStyle[myField].chunkWriters[ii] !=
                                    thisEpochStyle[myField].chunkWriters[jj]);
                        }
                    }
                }
            }
        }
        else {
            // This is a computational rank; create the intercommunicators
            // to the various split off separate field communicators.

            for (fieldIndex = 0;  fieldIndex < nF;  ++fieldIndex) {

                // Find the remote "root" process for this field
                int fieldRoot = -1;
                while (rankAssignments[++fieldRoot] != fieldIndex);

                // Create the intercomm for this field for this epoch style
                MPI_Intercomm_create(newIntracomm, 0, parentComm, fieldRoot,
                        fieldIndex, &(thisEpochStyle[fieldIndex].dataIntercomm));

                // ... and dup a separate one for tile registrations
                MPI_Comm_dup(thisEpochStyle[fieldIndex].dataIntercomm,
                         &(thisEpochStyle[fieldIndex].registrationIntercomm));
            }
        }


        // Print a "map" of the core assignments.  Compute nodes are indicated
        // by a "#" for the whole node, i/o nodes have the individual cores
        // within the node broken out and their field assignment printed.
        // If the core is writing to the disk, the field assignment is printed
        // in parentheses.
        if (0 == parentRank) {
            int fieldIOCounts[nF];
            memset (fieldIOCounts, 0, nF*sizeof(int));

            printf ("Writer assignments, epoch style %d\n", epochStyleIndex);
            for (i = 0;  i < nF;  ++i) {
                fieldInfoThisEpoch_t *p = &(thisEpochStyle[i]);
                int chunkSize = divCeil(p->zDepth,p->nChunks);
                printf ("\n");
                printf ( "field %2d ('%c'): %1d levels, %1d writers, %1d"
                         " levels per writer (last writer = %d levels)\n",
                        i, p->dataFieldID, p->zDepth, p->nChunks,
                        chunkSize, p->zDepth - ((p->nChunks - 1)*chunkSize));
                for (j = 0;  j < thisEpochStyle[i].nChunks;  ++j) {
                    printf (" %1d", thisEpochStyle[i].chunkWriters[j]);
                }
                printf ("\n");
            }
            printf ("\n");

            printf("\ncpu assignments, epoch style %d\n", epochStyleIndex);
            int whichIONode = -1;
            for (i = 0; i < numComputeNodes + numIONodes ; ++i) {

                if (rankAssignments[i*numRanksPerNode] >= 0) {

                    // i/o node
                    ++whichIONode;
                    printf("\n%s (%d Z, %ld bytes):",
                           &(allHostnames[i*numRanksPerNode][0]),
                           nToWrite[whichIONode],
                           nToWrite[whichIONode]*twoDFieldSizeInBytes);

                    for (j = 0; j < numRanksPerNode; ++j) {

                        int assignedField = rankAssignments[i*numRanksPerNode + j];
                        int k, commRank, nChunks, isWriter;
                        nChunks = thisEpochStyle[assignedField].nChunks;
                        commRank = fieldIOCounts[assignedField];

                        isWriter = 0;
                        for (k = 0;  k < nChunks;  ++k) {
                            if (thisEpochStyle[assignedField].chunkWriters[k] == commRank) {
                                isWriter = 1;
                                break;
                            }
                        }
                        printf(isWriter ? " (%1d)" : "  %1d ", assignedField);

                        fieldIOCounts[assignedField] += 1;
                    }
                    printf("\n");

                } else {

                    // compute node
                    for (j = 0; j < numRanksPerNode; ++j) {
                        if ((i*numRanksPerNode + j) >= (numComputeRanks + numIORanks)) break;
                        ASSERT(-1 == rankAssignments[i*numRanksPerNode + j]);
                    }
                    printf(" #");
                    for (; j < numRanksPerNode; ++j) {  // "excess" ranks (if any)
                        printf("X");
                    }
                }
                printf(" ");
            }
            printf("\n\n");
        }



    } // epoch style loop

    // Note: only non-null in rank 0, but it's ok to "free" NULL
    free(allHostnames);


    // I/O processes split off and start receiving data
    // NOTE: the I/O processes DO NOT RETURN from this call
    if (isIO == thisRanksType) ioRankMain();


    // The "compute" processes now return with their new intra-communicator.
    *rtnComputeComm = newIntracomm;

    // but first, call mpiio initialization routine!
    initSizesAndTypes();

    fflush (stdout);
    return;
}




// "Register" the tile-id(s) that this process will be sending
void
f2(int tileID)
{
    int i, epochStyleIndex;

    static int count = 0;

    // This code assumes that the same tileID will apply to all the
    // fields. Note that we use the tileID as a tag, so we require it
    // be an int with a legal tag value, but we do *NOT* actually use
    // the tag *value* for anything (e.g. it is NOT used as an index
    // into an array).  It is treated as an opaque handle that is
    // passed from the compute task(s) to the compositing routines.
    // Those two end-points likely assign meaning to the tileID (i.e.
    // use it to identify where the tile belongs within the domain),
    // but that is their business.
    //
    // A tileID of -1 signifies the end of registration.

    ASSERT(computeIntracommRank >= 0);

    if (tileID >= 0) {
        // In this version of the code, in addition to the tileID, we also
        // multiplex in the low order bit(s) of the epoch number as an
        // error check.  So the tile value must be small enough to allow that.
        ASSERT(((tileID<<numCheckBits) + ((1<<numCheckBits)-1)) < maxTagValue);

        // In this version of the code, we do not send the actual tileID's
        // to the i/o processes during the registration procedure.  We only
        // send a count of the number of tiles that we will send.
        ++count;
        return;
    }


    // We get here when we are called with a negative tileID, signifying
    // the end of registration.  We now need to figure out and inform
    // *each* i/o process in *each* field just how many tiles we will be
    // sending them in *each* epoch style.

    for (epochStyleIndex = 0;  epochStyleIndex < numEpochStyles;  ++epochStyleIndex) {
        fieldInfoThisEpoch_t *thisEpochStyle = epochStyles[epochStyleIndex];

        int curFieldIndex = -1;
        while ('\0' != thisEpochStyle[++curFieldIndex].dataFieldID) {
            fieldInfoThisEpoch_t *thisField = &(thisEpochStyle[curFieldIndex]);
            int numRemoteRanks, *tileCounts, remainder;
            MPI_Comm_remote_size(thisField->dataIntercomm, &numRemoteRanks);

            tileCounts = alloca(numRemoteRanks * sizeof(int));

	    memset(tileCounts,0,numRemoteRanks * sizeof(int));

            // Distribute the tiles among the i/o ranks.
            for (i = 0;  i < numRemoteRanks;  ++i) {
                tileCounts[i] = count / numRemoteRanks;
            }
            // Deal with any remainder
            remainder = count - ((count / numRemoteRanks) * numRemoteRanks);
            for (i = 0;  i < remainder;  ++i) {
                int target = (computeIntracommRank + i) % numRemoteRanks;
                tileCounts[target] += 1;
            }

            // Communicate these counts to the i/o processes for this
            // field.  Note that we send a message to each process,
            // even if the count is zero.
            for (i = 0;  i < numRemoteRanks;  ++i) {
                MPI_Send(NULL, 0, MPI_BYTE, i, tileCounts[i],
                         thisField->registrationIntercomm);
            }

        } // field loop
    } // epoch-style loop

}




int currentEpochID = 0;
int currentEpochStyle = 0;

void
beginNewEpoch(int newEpochID, int gcmIter, int epochStyle)
{
    fieldInfoThisEpoch_t *p;

    if (newEpochID != (currentEpochID + 1)) {
        fprintf(stderr, "ERROR: Missing i/o epoch?  was %d, is now %d ??\n",
                  currentEpochID, newEpochID);
        sleep(1); // Give the message a chance to propagate
        abort();
    }



    // not necessary for correctness, but for better timings
    MPI_Barrier(computeIntracomm);
    if (0 == computeIntracommRank)
      fprintf(stderr,"compute ready to emit %d %d %f\n",newEpochID,gcmIter,MPI_Wtime());



    ////////////////////////////////////////////////////////////////////////
    // Need to be sure the i/o tasks are done processing the previous epoch
    // before any compute tasks start sending tiles from a new epoch.

    if (0 == computeIntracommRank) {
      int cmd[4] = { cmd_newEpoch, newEpochID, epochStyle, gcmIter };

        // Wait to get an ack that the i/o tasks are done with the prior epoch.
        MPI_Recv(NULL, 0, MPI_BYTE, 0, cmd_epochComplete,
                 globalIntercomm, MPI_STATUS_IGNORE);

        // Tell the i/o ranks about the new epoch.
        // (Just tell rank 0; it will bcast to the others)
        MPI_Send(cmd, 4, MPI_INT, 0, 0, globalIntercomm);
    }

    // Compute ranks wait here until rank 0 gets the ack from the i/o ranks
    MPI_Barrier(computeIntracomm);

    if (0 == computeIntracommRank)
      fprintf(stderr,"compute handshake completed %d %d %f\n",newEpochID,gcmIter,MPI_Wtime());


    currentEpochID = newEpochID;
    currentEpochStyle = epochStyle;

    // Reset the tileCount (used by f3)
    for (p = epochStyles[currentEpochStyle];  p->dataFieldID != '\0'; ++p) {
        p->tileCount = 0;
    }
}


void
f3(char dataFieldID, int tileID, int epochID, void *data)
{
    int whichField, receiver, tag;

    static char priorDataFieldID = '\0';
    static int priorEpoch = -1;
    static int remoteCommSize;
    static fieldInfoThisEpoch_t *p;

    int flag=0;

    // Check that this global has been set
    ASSERT(computeIntracommRank >= 0);


    // Figure out some info about this dataFieldID.  It is
    // likely to be another tile from the same field as last time
    // we were called, in which case we can reuse the "static" values
    // retained from the prior call.  If not, we need to look it up.

    if ((dataFieldID != priorDataFieldID) || (epochID != priorEpoch)) {

        // It's not the same; we need to look it up.

        for (p = epochStyles[currentEpochStyle]; p->dataFieldID != '\0'; ++p) {
            if (p->dataFieldID == dataFieldID) break;
        }
        // Make sure we found a valid field
        ASSERT(p->dataIntercomm != MPI_COMM_NULL);

        MPI_Comm_remote_size(p->dataIntercomm, &remoteCommSize);

	flag=1;

    }
    
    ASSERT(p->dataFieldID == dataFieldID);

    receiver = (computeIntracommRank + p->tileCount) % remoteCommSize;
    tag = (tileID << numCheckBits) | (epochID & bitMask);

    FPRINTF(stderr,"Rank %d sends field '%c', tile %d, to i/o task %d with tag %d(%d)\n",
                   computeIntracommRank, dataFieldID, tileID, receiver, tag, tag >> numCheckBits);

    MPI_Send(data, tileOneZLevelSizeInBytes * p->zDepth,
             MPI_BYTE, receiver, tag, p->dataIntercomm);

    p->tileCount += 1;
    priorDataFieldID = dataFieldID;
    priorEpoch = epochID;
}



void
f4(int epochID)
{
    int i;
    ASSERT(computeIntracommRank >= 0);

    if (0 == computeIntracommRank) {
        int cmd[3] = { cmd_exit, -1, -1 };

        // Recv the ack that the prior i/o epoch is complete
        MPI_Recv(NULL, 0, MPI_BYTE, 0, cmd_epochComplete,
                 globalIntercomm, MPI_STATUS_IGNORE);

        // Tell the i/o ranks to exit
        // Just tell rank 0; it will bcast to the others
        MPI_Send(cmd, 3, MPI_INT, 0, 0, globalIntercomm);
    }

}



void asyncio_tile_arrays_(int *xoff, int *yoff, int *xskip)
{
    int rank, ierr, rootProc;

    MPI_Comm_rank(globalIntercomm,&rank);
    rootProc = (0 == rank) ? MPI_ROOT : MPI_PROC_NULL;

    ierr = MPI_Bcast (xoff, TOTAL_NUM_TILES, MPI_INT, rootProc, globalIntercomm);
    ierr = MPI_Bcast (yoff, TOTAL_NUM_TILES, MPI_INT, rootProc, globalIntercomm);
    ierr = MPI_Bcast (xskip, TOTAL_NUM_TILES, MPI_INT, rootProc, globalIntercomm);
}





//////////////////////////////////////////////////////////////////////
// Fortran interface

void
bron_f1(
  MPI_Fint *ptr_parentComm,
  int *ptr_numComputeRanks,
  int *ptr_numTiles,
  MPI_Fint *rtnComputeComm)
{
    // Convert the Fortran handle into a C handle
    MPI_Comm newComm, parentComm = MPI_Comm_f2c(*ptr_parentComm);

    f1(parentComm, *ptr_numComputeRanks, *ptr_numTiles, &newComm);

    // Convert the C handle into a Fortran handle
    *rtnComputeComm = MPI_Comm_c2f(newComm);
}



void
bron_f2(int *ptr_tileID)
{
    f2(*ptr_tileID);
}


void
beginnewepoch_(int *newEpochID, int *gcmIter, int *epochStyle)
{
  beginNewEpoch(*newEpochID, *gcmIter, *epochStyle);
}


void
bron_f3(char *ptr_dataFieldID, int *ptr_tileID, int *ptr_epochID, void *data)
{
    f3(*ptr_dataFieldID, *ptr_tileID, *ptr_epochID, data);
}



void
bron_f4(int *ptr_epochID)
{
    f4(*ptr_epochID);
}


