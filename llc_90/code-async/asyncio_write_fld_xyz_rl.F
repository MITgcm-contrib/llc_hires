C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_90/code-async/asyncio_write_fld_xyz_rl.F,v 1.1 2017/10/03 00:09:12 dimitri Exp $
C $Name:  $

#include "CPP_EEOPTIONS.h"
#include "W2_OPTIONS.h"
#include "RW_OPTIONS.h"

      SUBROUTINE ASYNCIO_WRITE_FLD_XYZ_RL( pref,suff,field,myIter,
     I           myThid )
      IMPLICIT NONE
C Global
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_PARAMS.h"
#include "W2_EXCH2_TOPOLOGY.h"
#include "PARAMS.h"
C Arguments
      CHARACTER*(*) pref,suff
      _RL field(1-Olx:sNx+Olx,1-Oly:sNy+Oly,Nr,nSx,nSy)
      INTEGER myIter
      INTEGER myThid
C Functions
      INTEGER ILNBLNK,IFNBLNK
C Local
      INTEGER bi, bj, IFLD, tN

      IFLD = ICHAR(pref)

C      RETURN
C
!      IF ( pref .EQ. 'U.' ) THEN
!         IFLD=1
!      ELSE IF (pref .EQ. 'V.' ) THEN
!         IFLD=2
!      ELSE IF (pref .EQ. 'T.' ) THEN
!         IFLD=3
!      ELSE IF (pref .EQ. 'S.' ) THEN
!         IFLD=4
!      ELSE IF (pref .EQ. 'X.' ) THEN
!         IFLD=5
!      ELSE IF (pref .EQ. 'Y.' ) THEN
!         IFLD=6
!      ELSE IF (pref .EQ. 'N.' ) THEN
!         IFLD=7
!      ELSE IF (pref .EQ. 'D.' ) THEN
!         IFLD=8
!      ELSE IF (pref .EQ. 'H.' ) THEN
!         IFLD=9
!      ELSE
!         STOP 'ABNORMAL END: INVALID FIELD CODE'
!      ENDIF

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
ch        tN = tileNo(bi,bj)
        tN = W2_myTileList(bi,bj)
ch        PRINT *, 'WRITING FOR TILE ', TN
        CALL ASYNCIO_BRON_F_F3( IFLD, TN, MYITER, 
     &   field(1-OLx,1-OLy,1,bi,bj)
     &  )
       ENDDO
      ENDDO

      RETURN
      END
