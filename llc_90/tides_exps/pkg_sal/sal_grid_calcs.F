#include "SAL_OPTIONS.h"

      SUBROUTINE SAL_GRID_CALCS(myTime,myIter,myThid)

      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
      _RL myTime
      INTEGER myIter
      INTEGER myThid

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      INTEGER  MDS_RECLEN
      EXTERNAL ILNBLNK
      EXTERNAL MDS_RECLEN

C     !LOCAL VARIABLES:
      INTEGER iUnit, filePrec, length_of_rec
      CHARACTER*512 fname
      INTEGER l, m, lm

C---Grid to SPH
      CALL SHTNS_SPAT_TO_SH(SAL_grid, SAL_lm)

      IF (SAL_cilmIter.GT.0 .AND. MOD(myIter,SAL_cilmIter).EQ.0) THEN
       WRITE(fname,'(A,I10.10,A)') 'SAL_cilm.',myIter,'.bin'
       filePrec = 64
       CALL MDSFINDUNIT( iUnit, myThid )
       length_of_rec = MDS_RECLEN(filePrec,SAL_NLM*2,myThid)
       OPEN(iUnit, file=fname, status='unknown', access='direct',
     &      recl=length_of_rec)
       WRITE(iUnit, rec=1) SAL_lm
       CLOSE(iUnit)
      ENDIF

C---Convolution step for SAL calculation
C     lm = (m*(2*lmax + 2 - (m+1)*mres))//2 + l + 1
C mres = 1:
C     lm = (m*(2*lmax + 2 - (m+1)))//2 + l + 1

      DO l=0,SAL_LMAX
       DO m=0,l
         CALL SHTNS_LMIDX(lm, l, m)
         SAL_lm(lm) = SAL_lm(lm)
     &     *(1 _d 0 + SAL_KLove(l+1) - SAL_HLove(l+1))/(2*l + 1)
     &     *3 _d 0*rhoConst/SAL_rhoEarth
       ENDDO
      ENDDO

      IF (SAL_cilmIter.GT.0 .AND. MOD(myIter,SAL_cilmIter).EQ.0) THEN
       WRITE(fname,'(A,I10.10,A)') 'SAL_cilm2.',myIter,'.bin'
       filePrec = 64
       CALL MDSFINDUNIT( iUnit, myThid )
       length_of_rec = MDS_RECLEN(filePrec,SAL_NLM*2,myThid)
       OPEN(iUnit, file=fname, status='unknown', access='direct',
     &      recl=length_of_rec)
       WRITE(iUnit, rec=1) SAL_lm
       CLOSE(iUnit)
      ENDIF

C---SPH to Grid
      CALL SHTNS_SH_TO_SPAT(SAL_lm, SAL_grid)

      RETURN
      END
