#include "SAL_OPTIONS.h"

CBOP
C     !ROUTINE: SAL_COMPUTE_MASS_ANOMALY
C     !INTERFACE:
      SUBROUTINE SAL_COMPUTE_MASS_ANOMALY(
     I                                     iniRef,
     I                                     myTime, myIter, myThid )
C     !DESCRIPTION: \bv
C     *==========================================================*
C     | SUBROUTINE SAL_COMPUTE_MASS_ANOMALY                      |
C     | o Copmute vertically integrated mass anomaly, either     |
C     |   from PHIBOTfv or from phiHydLow, and subtract a        |
C     |   time-independent reference mass anomaly                |
C     *==========================================================*
C     \ev
C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SURFACE.h"
#include "DYNVARS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     iniRef :: whether to set PHLSALref to current bottom pressure anom
C     myTime :: current time
C     myIter :: current iteration number
C     myThid :: thread number for this instance of the routine.
      LOGICAL iniRef
      _RL myTime
      INTEGER myIter, myThid

C     !FUNCTIONS:
#ifdef ALLOW_DIAGNOSTICS
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
#endif

C     !LOCAL VARIABLES:
C     == Local variables
C     bi, bj     :: tile indices
C     i, j       :: loop indices
C     iMin, iMax :: Ranges and sub-block indices on which calculations
C     jMin, jMax    are applied.
      INTEGER bi,bj
      INTEGER i,j
CEOP
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)

        DO j=1,sNy
         DO i=1,sNx
          IF (SAL_usePhiHydLow) THEN
C          use model bottom pressure anomaly from previous timestep
           PHLSAL(i,j,bi,bj) = phiHydLow(i,j,bi,bj)
          ELSE
C          use current finite-volume bottom pressure
           PHLSAL(i,j,bi,bj) = PHIBOTfv(i,j,bi,bj)
          ENDIF
         ENDDO
        ENDDO

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
c Adjust PHLSAL to remove topography-like signal
C - if no reference file given, use initial bottom pressure anomaly
C - NB: this breaks restarts unless read in from PHLSALini.data
        IF (iniRef) THEN
         DO j=1,sNy
          DO i=1,sNx
           PHLSALref(i,j,bi,bj) = PHLSAL(i,j,bi,bj)
          ENDDO
         ENDDO
        ENDIF

C Subtract reference bottom pressure
        DO j=1,sNy
         DO i=1,sNx
          PHLSAL(i,j,bi,bj)=(PHLSAL(i,j,bi,bj)-PHLSALref(i,j,bi,bj))
         ENDDO
        ENDDO

C mask land if requested
        IF (SAL_maskLand) THEN
         DO j=1,sNy
          DO i=1,sNx
           PHLSAL(i,j,bi,bj)=PHLSAL(i,j,bi,bj)*maskInC(i,j,bi,bj)
          ENDDO
         ENDDO
        ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C-    end of bi,bj loops
       ENDDO
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
       CALL DIAGNOSTICS_FILL(PHLSAL,'PHLSAL  ',0, 1,0,1,1,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

      IF (iniRef) THEN
       CALL WRITE_FLD_XY_RL('PHLSALini',' ',PHLSALref,myIter,myThid)
      ENDIF

      RETURN
      END
