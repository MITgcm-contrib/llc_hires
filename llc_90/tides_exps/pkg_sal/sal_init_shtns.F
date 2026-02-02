#include "SAL_OPTIONS.h"

      SUBROUTINE SAL_INIT_SHTNS(myThid)

      IMPLICIT NONE
C     == Global variables ===
#include "shtns.f"
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid - Thread number for this instance of the routine.
      INTEGER  myThid

C !FUNCTIONS
      INTEGER  ILNBLNK
      INTEGER  MDS_RECLEN
      EXTERNAL ILNBLNK
      EXTERNAL MDS_RECLEN

C     LOCAL VARIABLES:
      LOGICAL someLats, allLats
      INTEGER*4 lmax, mmax, mres, norm, layout, nlat, nphi
      INTEGER i, ierr
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      REAL*8 eps_polar
      REAL*8 costheta(SAL_NLAT)
      REAL*8 wgt((SAL_NLAT+1)/2)

      _BEGIN_MASTER( mythid )

C check all Gaussian latitudes were given
      someLats = .FALSE.
      allLats = .TRUE.
      DO i=1,SAL_NLAT
       IF (SAL_lat(i) .EQ. UNSET_RL) THEN
        allLats = .FALSE.
       ELSE
        someLats = .TRUE.
       ENDIF
      ENDDO
      IF (someLats .AND. .NOT. allLats) THEN
       WRITE(msgBuf,'(2A)') 'SAL_INIT_SHTNS:',
     &                      ' Some latitude values are missing.'
       CALL PRINT_ERROR( msgBuf , 1)
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R SAL_INIT_SHTNS'
      ENDIF

      IF (myProcId .eq. 0) THEN

        CALL SHTNS_VERBOSE(1)
        CALL SHTNS_USE_THREADS(0)

        nlat = SAL_NLAT
        nphi = SAL_NLON
        lmax = SAL_LMAX
        mmax = SAL_LMAX
        mres = 1
C        CALL SHTNS_CALC_NLM(nlm, lmax, mmax, mres)
C        nlm = SAL_NLM

        norm = SHT_FOURPI
        CALL SHTNS_SET_SIZE(lmax, mmax, mres, norm)

        WRITE(msgBuf,'(2A)') 'SAL_INIT_SHTns:',
     &       ' precomputing'
        CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                     SQUEEZE_RIGHT,myThid)
        layout = SHT_THETA_CONTIGUOUS
        IF (SAL_LoadSaveCfg) layout = layout + SHT_LOAD_SAVE_CFG
        eps_polar = 1D-10
        CALL SHTNS_PRECOMPUTE(SHT_GAUSS, layout, eps_polar, nlat, nphi)

C compute Gaussian latitudes if none given
        IF (.NOT.allLats) THEN
         CALL SHTNS_COS_ARRAY(costheta)
         DO i=1,SAL_NLAT
          SAL_lat(i) = ASIN(costheta(i))/deg2rad
         ENDDO
        ENDIF

C compute Gaussian weights
        CALL SHTNS_GAUSS_WTS(wgt)
        DO i=1,(SAL_NLAT+1)/2
         SAL_wgt(i) = wgt(i)
        ENDDO

      ENDIF

#ifdef ALLOW_USE_MPI
      IF ( usingMPI .AND. .NOT. allLats) THEN
       CALL TIMER_START('SAL_BCAST        [SAL_INIT_SHTNS]',myThid)
       CALL MPI_BCAST(SAL_lat,SAL_NLAT,MPI_DOUBLE_PRECISION,
     &                0,MPI_COMM_MODEL,ierr)
       CALL TIMER_STOP ('SAL_BCAST        [SAL_INIT_SHTNS]',myThid)
      ENDIF
#endif /* ALLOW_USE_MPI */

      _END_MASTER( mythid )

      _BARRIER

      RETURN
      END
