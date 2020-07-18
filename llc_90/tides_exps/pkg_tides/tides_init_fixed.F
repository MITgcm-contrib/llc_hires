#include "TIDES_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: TIDES_INIT_FIXED

C !INTERFACE:
      SUBROUTINE TIDES_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize TIDES variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
#include "EEPARAMS.h"
#include "TIDES_PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

#ifdef ALLOW_TIDES

C     !LOCAL VARIABLES:
C     === Local variables ===
      INTEGER dm
      REAL*8 GM
 
      _BEGIN_MASTER(myThid)

C     initialize SPICE library
      CALL FURNSH( tides_metaKernel )

C     get grav.constant times mass and convert to m^3/s^2
      CALL BODVRD('SUN', 'GM', 1, dm, GM)
      tides_sunGM = GM*1 _d 9

      CALL BODVRD('MOON', 'GM', 1, dm, GM)
      tides_moonGM = GM*1 _d 9

      _END_MASTER(myThid)
      _BARRIER

#endif /* ALLOW_TIDES */

      RETURN
      END
