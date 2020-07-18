#include "TIDES_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: TIDES_READPARMS

C !INTERFACE:
      SUBROUTINE TIDES_READPARMS( myThid )

C     !DESCRIPTION:
C     Initialize TIDES variables and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "TIDES_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_TIDES

C     !LOCAL VARIABLES:
C     msgBuf     :: Informational/error message buffer
C     iUnit      :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit

      NAMELIST /TIDES_PARM01/
     &       tides_orientData, tides_metaKernel,
     &       tides_earthRadius,
     &       tides_h2, tides_k2,
     &       tides_permC0, tides_permC1

      IF ( .NOT.useTIDES ) THEN
C-    pkg TIDES is not used
        _BEGIN_MASTER(myThid)
C-    Track pkg activation status:
C     print a (weak) warning if data.tides is found
         CALL PACKAGES_UNUSED_MSG( 'useTIDES', ' ', ' ' )
        _END_MASTER(myThid)
        RETURN
      ENDIF

      _BEGIN_MASTER(myThid)

C--   Default values
      tides_orientData = 'IAU_EARTH'
      tides_metaKernel = ' '
C     tides_earthRadius = rSphere
      tides_earthRadius = 6371 _d 3
      tides_h2 = 0.61 _d 0
      tides_k2 = 0.3 _d 0
C     permanent tide coefficients from HW95
      tides_permC0 = 0.8695487585 _d 0
      tides_permC1 = 0.0002826064 _d 0

      WRITE(msgBuf,'(A)') 'TIDES_READPARMS: opening data.tides'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                     'data.tides', 'TIDES_READPARMS',
     O                     iUnit,
     I                     myThid )

C     Read parameters from open data file
      READ(UNIT=iUnit,NML=TIDES_PARM01)
      WRITE(msgBuf,'(A)')
     &    'TIDES_READPARMS: finished reading data.tides'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &    SQUEEZE_RIGHT , 1)
C     Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_TIDES */

      RETURN
      END
