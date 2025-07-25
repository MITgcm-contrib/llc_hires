#include "CPP_EEOPTIONS.h"
 
      SUBROUTINE ASYNCIO_DRIVER_INIT(
     I            mpiCommIO, mpiCommParent,
     I            sNx, sNy, Nr, OLx, OLy )
      INTEGER mpiCommIO, mpiCommParent
      INTEGER sNx, sNy, Nr, OLx, OLy

      INTEGER IFNBLNK, ILNBLNK, I0, I1
      INTEGER  mpiRC

C--   Driver for separate asynchronous I/O processes
C--   Bron is writing real code for this
      INTEGER parCtxRank, parCtxNP
      INTEGER ioCtxRank,  ioCtxNP

      CHARACTER*1024 msgBuf

      CALL MPI_COMM_SIZE(mpiCommParent, parCtxNP,   mpiRC )
      CALL MPI_COMM_RANK(mpiCommParent, parCtxRank, mpiRC )

      CALL MPI_COMM_SIZE(mpiCommIO,     ioCtxNP,    mpiRC )
      CALL MPI_COMM_RANK(mpiCommIO,     ioCtxRank,  mpiRC )

      WRITE(msgBuf,'(A,I6,A,I6,A,I6,A,I6)') 
     &'Parent rank ',parCtxRank,' of ',parCtxNP,
     &' dedicated for I/O as rank ',ioCtxRank,' of ',ioCtxNP
      I0=IFNBLNK(msgBuf)
      I1=ILNBLNK(msgBuf)
      PRINT *, msgBuf(I0:I1)

      RETURN
      END
