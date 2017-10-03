C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_90/code-async/asyncio_init.F,v 1.1 2017/10/03 00:09:12 dimitri Exp $
#include "CPP_EEOPTIONS.h"

      SUBROUTINE ASYNCIO_INIT(
     I           mpiCommParent,
     U           mpiCommCompute )

      IMPLICIT NONE
#include "SIZE.h"

      INTEGER  mpiCommParent, mpiCommCompute

      INTEGER  mpiRC
      INTEGER  mpiCommIO
      INTEGER  mpiParentNP
      INTEGER  myParentRank

      INTEGER  mpiMyColor
      INTEGER  mpiComputeNP
      INTEGER  mpiIONP
      INTEGER  totalNumTiles
      INTEGER  numComputeProcesses

      CALL MPI_COMM_SIZE(mpiCommParent, mpiParentNP,  mpiRC )
      CALL MPI_COMM_RANK(mpiCommParent, myParentRank, mpiRC )

C--   Hand control of I/O ranks to I/O library code.
C--   Get back communicator for compute ranks to use.
      totalNumTiles       = nPx*nPy*nSx*nSy
      numComputeProcesses = nPx*nPy
      IF ( myParentRank .EQ. 0 ) THEN
       PRINT *, 'totalNumTiles ',totalNumTiles
       PRINT *, 'numComputeProcesses ', numComputeProcesses
      ENDIF
      CALL ASYNCIO_BRON_F_F1(mpiCommParent,
     I                       numComputeProcesses,
     I                       totalNumTiles,
     O                       mpiCommCompute)
      RETURN

C--   ** MOST CODE FROM HERE IS PLACE HOLDER UNTIL WORKING
C--   ** BRON CODE EXISTS
C--   Distribute procs to "compute pool" and "I/O pool"
      mpiCommIO      = -1
      mpiCommCompute = -1
!     mpiComputeNP = mpiParentNP*3/4
      mpiComputeNP = npx*npy
      mpiIONP      = mpiParentNP-mpiComputeNP

      IF ( myParentRank .GE. mpiComputeNP ) THEN
       mpiMyColor=1
      ELSE
       mpiMyColor=2
      ENDIF

      IF    ( mpiMyColor .EQ. 1 ) THEN
       CALL MPI_COMM_SPLIT(mpiCommParent, mpiMyColor, 0, mpiCommIO,
     &      mpiRC )
      ELSE
       CALL MPI_COMM_SPLIT(mpiCommParent, mpiMyColor, 0, mpiCommCompute,
     &      mpiRC)
      ENDIF

      IF ( mpiCommIO .NE. -1 ) THEN
       CALL ASYNCIO_DRIVER_INIT(
     I                          mpiCommIO, mpiCommParent,
     I                          sNx, sNy, Nr, OLx, OLy
     I                        )
C--    ** WILL NEED SOMETHING LIKE THESE THREE LINES EVEN
C--    ** AFTER BRON CODE
       CALL MPI_BARRIER(mpiCommParent,mpiRC)
       CALL MPI_FINALIZE(mpiRC)
       STOP 'NORMAL END: ASYNC IO PROCS'
      ENDIF
  
      RETURN
      END
