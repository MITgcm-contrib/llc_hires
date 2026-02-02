#include "SAL_OPTIONS.h"

CBOP
C     !ROUTINE: SAL_APPLY
C     !INTERFACE:
      SUBROUTINE SAL_APPLY(myTime, myIter, myThid)
C     !DESCRIPTION:
C     *==========================================================*
C     | SUBROUTINE SAL_APPLY
C     | o Controlling routine for sal package
C     *==========================================================*

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "FFIELDS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myTime :: Current time in simulation
C     myIter :: Current iteration number in simulation
C     myThid :: Thread number for this instance of the routine.
      _RL myTime
      INTEGER myIter
      INTEGER myThid

C     !LOCAL VARIABLES:
C     == Local variables
C     bi, bj        :: tile indices
C     msgBuf        :: Temp. for building output string
C     i,j           :: loop indices
      INTEGER bi, bj
      INTEGER i, j
      LOGICAL iniRef
      CHARACTER*(MAX_LEN_MBUF) msgBuf
CEOP

#ifdef ALLOW_SAL

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
       CALL DIAGNOSTICS_FILL(phiTide2d,'SALptid0',0, 1,0,1,1,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

C     do we have to initialize PFLSALref?
      iniRef = SAL_refFile.EQ.' ' .AND. (myIter.EQ.nIter0 .OR.
     &  (myTime.GE.SAL_startTime .AND. myTime-deltaT.LT.SAL_startTime))

C     this computes MASS anomaly diagnostic even before starttime
      CALL SAL_COMPUTE_MASS_ANOMALY(iniRef, myTime, myIter, myThid)

      IF (myTime .GE. SAL_startTime) THEN

c      compute SAL forcing (SAL) from PHLSAL:
       CALL SAL_COMPUTE_LOADING(myTime, myIter, myThid)

c      subtract from geopotential
       DO bj=myByLo(myThid),myByHi(myThid)
        DO bi=myBxLo(myThid),myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           phiTide2d(i,j,bi,bj) = phiTide2d(i,j,bi,bj) - SAL(i,j,bi,bj)
          ENDDO
         ENDDO
        ENDDO
       ENDDO

      ENDIF

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
       CALL DIAGNOSTICS_FILL(SAL,'SAL     ',0, 1,0,1,1,myThid)
       CALL DIAGNOSTICS_FILL(phiTide2d,'SALptid1',0, 1,0,1,1,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

#endif /* ALLOW_SAL */

      RETURN
      END
