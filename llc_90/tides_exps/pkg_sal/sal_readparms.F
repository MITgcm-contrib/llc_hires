#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: SAL_READPARMS

C !INTERFACE:
      SUBROUTINE SAL_READPARMS( myThid )

C     !DESCRIPTION:
C     Initialize SAL variables and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_SAL

C     !LOCAL VARIABLES:
C     msgBuf     :: Informational/error message buffer
C     iUnit      :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit, i

      NAMELIST /SAL_PARM01/
     &   SAL_maskLand,
     &   SAL_usePhiHydLow,
     &   SAL_LoveFile,
     &   SAL_refFile,
     &   SAL_loadSaveCfg,
     &   SAL_model2llFile,
     &   SAL_ll2modelMethod,
     &   SAL_lon_0,
     &   SAL_lat,
     &   SAL_rhoEarth,
     &   SAL_startTime,
     &   SAL_diagIter,
     &   SAL_cilmIter

      IF ( .NOT.useSAL ) THEN
C-    pkg SAL is not used
        _BEGIN_MASTER(myThid)
C-    Track pkg activation status:
C     print a (weak) warning if data.sal is found
         CALL PACKAGES_UNUSED_MSG( 'useSAL', ' ', ' ' )
        _END_MASTER(myThid)
        RETURN
      ENDIF

      _BEGIN_MASTER(myThid)

C--   Default values for SAL
      SAL_LoveFile = 'Love.txt'
      SAL_refFile = ' '
      SAL_loadSaveCfg = .FALSE.
      SAL_model2llFile = ' '
      SAL_startTime = baseTime
      SAL_lon_0 = 0 _d 0
      SAL_ll2modelMethod = 2
      SAL_diagIter = 0
      SAL_cilmIter = 0
      SAL_usePhiHydLow = .FALSE.
      SAL_maskLand = .TRUE.
      SAL_rhoEarth = 5517 _d 0
      DO i=1,SAL_NLAT
        SAL_lat(i) = UNSET_RL
      ENDDO

      WRITE(msgBuf,'(A)') 'SAL_READPARMS: opening data.sal'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I                     'data.sal', 'SAL_READPARMS',
     O                     iUnit,
     I                     myThid )

C     Read parameters from open data file
      READ(UNIT=iUnit,NML=SAL_PARM01)
      WRITE(msgBuf,'(A)')
     &    'SAL_READPARMS: finished reading data.sal'
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

#endif /* ALLOW_SAL */

      RETURN
      END
