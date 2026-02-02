#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: SAL_INIT_FIXED

C !INTERFACE:
      SUBROUTINE SAL_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize SAL variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     === Local variables ===
      _RL h, l, k, nk, h1, l1, k1
      INTEGER iUnit, i, n, nmax, ios
      CHARACTER*(MAX_LEN_MBUF) msgBuf

C--   read load Love numbers

      DO n = 1,SAL_MAXNLOVE
        SAL_hLove(n) = 0 _d 0
        SAL_lLove(n) = 0 _d 0
        SAL_kLove(n) = 0 _d 0
      ENDDO

#ifdef SAL_OLD_LOVEFILE
      CALL MDSFINDUNIT( iUnit, myThid )
      OPEN(iUnit,FILE=SAL_LoveFile,STATUS='old',FORM='formatted')
      ios = 0
      DO i = 1,SAL_MAXNLOVE
        READ(iUnit,'(I4,2F10.6)',IOSTAT=ios) n,h,nk
        IF (ios .NE. 0) EXIT
        SAL_HLove(n) = h
        SAL_KLove(n) = nk/n
      ENDDO
      CLOSE(iUnit)
#else
      CALL MDSFINDUNIT( iUnit, myThid )
      OPEN(iUnit,FILE=SAL_LoveFile,STATUS='old',FORM='formatted')
      nmax = -1
      DO WHILE (nmax .LT. SAL_MAXNLOVE-1)
        ios = 0
        READ(iUnit,'(I6,3F18.18)',IOSTAT=ios) n,h,l,k
        IF (ios .EQ. 0) THEN
          IF (n .EQ. nmax+1 .OR. (n.EQ.1 .AND. nmax.EQ.-1)) THEN
C           SAL_hLove(1) is h_0, etc
            SAL_hLove(n+1) = h
            SAL_lLove(n+1) = l
            SAL_kLove(n+1) = k
            nmax = n
          ELSE
            EXIT
          ENDIF
        ELSE
          IF (nmax .NE. -1) EXIT
        ENDIF
      ENDDO
      CLOSE(iUnit)
      IF (nmax .NE. SAL_MAXNLOVE-1) THEN
        WRITE(msgBuf,'(2A,I5,A,I5)') 'SAL_INIT_FIXED: ',
     &   'Could not read all Love numbers: ',nmax,' vs ',SAL_MAXNLOVE
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( myThid )
        STOP 'ABNORMAL END: S/R SAL_INIT_FIXED (SAL_LoveFile)'
      ENDIF
#endif

C     no need to convert to a different reference frame:
C     the body potential coefficient 1 + k' - h' is frame independent

      WRITE(msgBuf,'(A)') 'SAL_INIT_FIXED: load Love numbers:'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      WRITE(msgBuf,'(A4,2A18)') '   n', 'h', 'k'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      DO n = 1,SAL_MAXNLOVE
       WRITE(msgBuf,'(I5,2G18.10)') n-1, SAL_hLove(n), SAL_kLove(n)
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
      ENDDO

      CALL SAL_INIT_SHTNS( myThid )

      WRITE(msgBuf,'(A)') 'SAL_INIT_FIXED: intermediate grid lats:'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      WRITE(msgBuf,'(A5,A25)') 'n', 'lat'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      DO n = 1,SAL_NLAT
       WRITE(msgBuf,'(I5,F25.20)') n, SAL_lat(n)
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
      ENDDO

      _BEGIN_MASTER( mythid )
      IF (myProcId .EQ. 0) THEN
       WRITE(msgBuf,'(A)') 'SAL_INIT_FIXED: intermediate grid weights:'
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
       WRITE(msgBuf,'(A5,A25)') 'n', 'wgt'
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
       DO n = 1,(SAL_NLAT+1)/2
        WRITE(msgBuf,'(I5,F25.20)') n, SAL_wgt(n)
        CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                     SQUEEZE_RIGHT,myThid)
       ENDDO
      ENDIF
      _END_MASTER( mythid )

C--   Read/compute interpolation matrices

      IF (SAL_model2llFile .NE. ' ') THEN
C      read arrays for interpolation from model to lat-lon grid
       CALL SAL_INIT_MODEL2LL(myThid)
      ELSE
C      use nearest-neighbor interpolation
       CALL SAL_INIT_NEAREST(myThid)
      ENDIF

#ifdef ALLOW_DIAGNOSTICS
      IF (useDiagnostics) THEN
       CALL SAL_DIAGNOSTICS_INIT(myThid)
      ENDIF
#endif

      RETURN
      END
