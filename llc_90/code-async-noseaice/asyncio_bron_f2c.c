#include <mpi.h>
void bron_f1(MPI_Comm *, int *, int *, MPI_Comm *);
void bron_f2(int *);
void bron_f3(char *, int *, int *, void *);
void bron_f4(int *);

// Initialization function. 
// Only compute ranks return.
void asyncio_bron_f_f1_( MPI_Comm *mpiCommParent,
                         int *mpiComputeNP,
                         int *totalNumTiles,
                         MPI_Comm *mpiCommCompute ) { 
 bron_f1(mpiCommParent, mpiComputeNP, totalNumTiles, mpiCommCompute );
}

// Each compute rank calls this to register the
// tileID(s) it owns. For multiple tileIDs per
// rank call multiple times. Indicate that 
// registration is finished by calling with tileID=-1
void asyncio_bron_f_f2_( int *tileID ) {
 bron_f2(tileID);
}

// Call this from each rank to post data for writing.
// fldNum is a numeric code for field to write (passing strings between
// Fortran and C is a pain). epochID is timestep number.
void asyncio_bron_f_f3_( int *fldNum, int *tileID, int *epochID, void *data){
 char fldCode;
 //if ( *fldNum == 1 ) { fldCode='u'; }
 //if ( *fldNum == 2 ) { fldCode='v'; }
 //if ( *fldNum == 3 ) { fldCode='t'; }
 //if ( *fldNum == 4 ) { fldCode='s'; }
 //if ( *fldNum == 5 ) { fldCode='x'; }
 //if ( *fldNum == 6 ) { fldCode='y'; }
 //if ( *fldNum == 7 ) { fldCode='n'; }
 //if ( *fldNum == 8 ) { fldCode='d'; }
 //if ( *fldNum == 9 ) { fldCode='h'; }

 //if ( *fldNum == 10 ) { fldCode='a'; }  // seaice fields
 //if ( *fldNum == 11 ) { fldCode='b'; }
 //if ( *fldNum == 12 ) { fldCode='c'; }
 //if ( *fldNum == 13 ) { fldCode='d'; }
 //if ( *fldNum == 14 ) { fldCode='e'; }
 //if ( *fldNum == 15 ) { fldCode='f'; }
 //if ( *fldNum == 16 ) { fldCode='g'; }
 fldCode = *fldNum;
 bron_f3(&fldCode, tileID, epochID, data);
}

// Call this once from one rank to make I/O ranks clean up and
// finish/return. Indicate that the compute 
// ranks are done processing and sending data.
void asyncio_bron_f_f4_( int *epochID ){
 bron_f4(epochID);
}
