#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: SAL_INIT_VARIA

C !INTERFACE:
      SUBROUTINE SAL_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize SAL variables that vary during the run.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_SAL

C     !LOCAL VARIABLES:
C     === Local variables ===
      INTEGER i,j,bi,bj
      CHARACTER*(MAX_LEN_FNAM) fname

      IF (SAL_refFile .NE. ' ') THEN
       CALL READ_FLD_XY_RL( SAL_refFile, ' ', PHLSALref, 0, myThid )
       CALL EXCH_XY_RL( PHLSALref, myThid )
      ELSE
       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           PHLSALref(i,j,bi,bj) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDIF

C     initialize SAL in case needed for diagnostic before SAL_startTime
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          SAL(i,j,bi,bj) = 0. _d 0
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      IF ( startTime.GE.SAL_startTime .AND. SAL_usePhiHydLow ) THEN
C       using phiHydLow, so have to read from pickup
        CALL SAL_READ_PICKUP( nIter0, myThid )
      ENDIF

#endif /* ALLOW_SAL */

      RETURN
      END
