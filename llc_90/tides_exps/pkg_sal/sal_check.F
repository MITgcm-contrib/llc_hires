#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: SAL_CHECK

C !INTERFACE:
      SUBROUTINE SAL_CHECK( myThid )

C     !DESCRIPTION:
C     Check dependances with other packages

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_SAL
C     !LOCAL VARIABLES:
C     msgBuf   :: Informational/error message buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      _BEGIN_MASTER(myThid)

       WRITE(msgBuf,'(A)') 'SAL_CHECK: #define SAL'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT , 1)

C--  Print out some key parameters:

C--  Check parameters:

       IF (SAL_NLON.NE.SAL_NLAT .AND. SAL_NLON.NE.2*SAL_NLAT) THEN
        WRITE(msgBuf,'(2A)') 'SAL_CHECK:',
     &       ' SAL_NLON must equal SAL_NLAT or 2*SAL_NLAT'
        CALL PRINT_ERROR( msgBuf , 1)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R SAL_CHECK'
       ENDIF

       IF (SAL_ll2modelMethod.LT.1 .OR. SAL_ll2modelMethod.GT.2) THEN
        WRITE(msgBuf,'(2A)') 'SAL_CHECK:',
     &       ' SAL_ll2modelMethod must be 1 or 2'
        CALL PRINT_ERROR( msgBuf , 1)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R SAL_CHECK'
       ENDIF

#ifndef INCLUDE_PHIHYD_CALCULATION_CODE
       IF ( SAL_usePhiHydLow ) THEN
        WRITE(msgBuf,'(A)') 'SAL_CHECK: sal pkg requires'
        WRITE(msgBuf,'(2A)') 'SAL_CHECK:'
     &       ' need #define INCLUDE_PHIHYD_CALCULATION_CODE'
        CALL PRINT_ERROR( msgBuf , 1)
        WRITE(msgBuf,'(2A)') 'SAL_CHECK: in CPP_OPTIONS.h'
             ' if SAL_usePhiHydLow = .TRUE..'
        CALL PRINT_ERROR( msgBuf , 1)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R SAL_CHECK'
       ENDIF
#endif

#ifndef INCLUDE_PHIBOT_FV_CODE
       IF ( .NOT. SAL_usePhiHydLow ) THEN
        WRITE(msgBuf,'(2A)') 'SAL_CHECK:'
     &       ' need #define INCLUDE_PHIBOT_FV_CODE'
        CALL PRINT_ERROR( msgBuf , 1)
        WRITE(msgBuf,'(2A)') 'SAL_CHECK: in CPP_OPTIONS.h'
             ' if SAL_usePhiHydLow = .FALSE..'
        CALL PRINT_ERROR( msgBuf , 1)
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R SAL_CHECK'
       ENDIF
#endif

      _END_MASTER(myThid)

#endif /* ALLOW_SAL */

      RETURN
      END
