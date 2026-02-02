#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: CALC_PHIBOT_FV
C     !INTERFACE:
      SUBROUTINE CALC_PHIBOT_FV( myTime, myIter, myThid )
C     *==========================================================*
C     | SUBROUTINE CALC_PHIBOT_FV                                |
C     | o Integrate the in-situ density to find the 2-D mass     |
C     |   anomaly                                                |
C     | o This is basically he bouyancy relation 'OCEANIC',      |
C     |   integr_GeoPot=1 part of calc_phi_hyd.                  |
C     *==========================================================*
C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "SIZE.h"
#include "GRID.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SURFACE.h"
#include "DYNVARS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myTime :: current time
C     myIter :: current iteration number
C     myThid :: thread number for this instance of the routine.
      LOGICAL iniRef
      _RL myTime
      INTEGER myIter, myThid

#ifdef INCLUDE_PHIBOT_FV_CODE

C     !FUNCTIONS:
#ifdef ALLOW_DIAGNOSTICS
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
#endif

C     !LOCAL VARIABLES:
C     == Local variables
C     phiHydC    :: hydrostatic potential anomaly at cell center
C                   In z coords phiHyd is the hydrostatic potential
C                      (=pressure/rho0) anomaly
C                   In p coords phiHyd is the geopotential height anomaly.
C     phiHydF    :: hydrostatic potential anomaly at middle between 2 centers
C     iMin, iMax :: Ranges and sub-block indices on which calculations
C     jMin, jMax    are applied.
C     bi, bj     :: tile indices
C     k          :: current level index
      INTEGER bi,bj
      INTEGER i,j,k
      _RL phiHydF (1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL phiHydC (1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL alphaRho(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL ddRloc
      _RL surfPhiFac
      LOGICAL addSurfPhiAnom
#ifdef NONLIN_FRSURF
      _RL dPhiRef
#endif /* NONLIN_FRSURF */
      INTEGER iMin, iMax
      INTEGER jMin, jMax
      PARAMETER( iMin = 1 , iMax = sNx )
      PARAMETER( jMin = 1 , jMax = sNy )
CEOP
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

      addSurfPhiAnom = select_rStar.EQ.0 .AND. nonlinFreeSurf.GE.4

      surfPhiFac = 0.
      IF (addSurfPhiAnom) surfPhiFac = 1.

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)

C--   Initialize phiHydF to zero :
C     note: atmospheric_loading or Phi_topo anomaly are incorporated
C           later in S/R calc_grad_phi_hyd
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          phiHydF(i,j) = 0. _d 0
          phiHydC(i,j) = 0. _d 0
          PHIBOTfv(i,j,bi,bj) = 0. _d 0
         ENDDO
        ENDDO

C--     Start of dynamics loop
        DO k=1,Nr

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C       This is the hydrostatic pressure calculation for the Ocean
C       which uses the FIND_RHO() routine to calculate density
C       before integrating g*rho over the current layer/interface

          IF ( myIter.LT.0 ) THEN
C---      Calculate density
            CALL FIND_RHO_2D(
     I                iMin, iMax, jMin, jMax, k,
     I                theta(1-OLx,1-OLy,k,bi,bj),
     I                salt(1-OLx,1-OLy,k,bi,bj),
     O                alphaRho,
     I                k, bi, bj, myThid )
          ELSE
            DO j=jMin,jMax
             DO i=iMin,iMax
               alphaRho(i,j) = rhoInSitu(i,j,k,bi,bj)
             ENDDO
            ENDDO
          ENDIF

#ifdef ALLOW_SHELFICE
C     mask rho, so that there is no contribution of phiHyd from
C     overlying shelfice (whose density we do not know)
          IF ( useShelfIce .AND. useDOWN_SLOPE ) THEN
C- note: does not work for down_slope pkg which needs rho below the bottom.
C    setting rho=0 above the ice-shelf base is enough (and works in both cases)
C    but might be slower (--> keep original masking if not using down_slope pkg)
           DO j=jMin,jMax
            DO i=iMin,iMax
             IF ( k.LT.kSurfC(i,j,bi,bj) ) alphaRho(i,j) = 0. _d 0
            ENDDO
           ENDDO
          ELSEIF ( useShelfIce ) THEN
           DO j=jMin,jMax
            DO i=iMin,iMax
             alphaRho(i,j) = alphaRho(i,j)*maskC(i,j,k,bi,bj)
            ENDDO
           ENDDO
          ENDIF
#endif /* ALLOW_SHELFICE */

#ifdef NONLIN_FRSURF
          IF ( addSurfPhiAnom .AND.
     &         uniformFreeSurfLev .AND. k.EQ.1 ) THEN
           DO j=jMin,jMax
            DO i=iMin,iMax
              phiHydF(i,j) = surfPhiFac*etaH(i,j,bi,bj)
     &                      *gravity*alphaRho(i,j)*recip_rhoConst
            ENDDO
           ENDDO
          ENDIF
#endif /* NONLIN_FRSURF */

C----  Hydrostatic pressure at cell centers

C---------- This discretization is the "finite volume" form
C           which has not been used to date since it does not
C           conserve KE+PE exactly even though it is more natural

          IF ( uniformFreeSurfLev ) THEN
           DO j=jMin,jMax
            DO i=iMin,iMax
             phiHydC(i,j) = phiHydF(i,j)
     &              + halfRL*drF(k)*gravFacC(k)*gravity
     &                             *alphaRho(i,j)*recip_rhoConst
             phiHydF(i,j) = phiHydF(i,j)
     &                     + drF(k)*gravFacC(k)*gravity
     &                             *alphaRho(i,j)*recip_rhoConst
            ENDDO
           ENDDO
          ELSE
           DO j=jMin,jMax
            DO i=iMin,iMax
             IF (k.EQ.kSurfC(i,j,bi,bj)) THEN
              ddRloc = Ro_surf(i,j,bi,bj)-rC(k)
#ifdef NONLIN_FRSURF
              ddRloc = ddRloc + surfPhiFac*etaH(i,j,bi,bj)
#endif
              phiHydC(i,j) = ddRloc*gravFacC(k)*gravity
     &                           *alphaRho(i,j)*recip_rhoConst
             ELSE
              phiHydC(i,j) = phiHydF(i,j)
     &              + halfRL*drF(k)*gravFacC(k)*gravity
     &                             *alphaRho(i,j)*recip_rhoConst
             ENDIF
             phiHydF(i,j) = phiHydC(i,j)
     &              + halfRL*drF(k)*gravFacC(k)*gravity
     &                             *alphaRho(i,j)*recip_rhoConst
            ENDDO
           ENDDO
          ENDIF
C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C----- Compute bottom pressure deviation from gravity*rho0*H
C      Start from phiHyd at the (bottom) tracer point and add Del_h*g*rho_prime
C      with Del_h = distance from the bottom up to tracer point

         DO j=jMin,jMax
          DO i=iMin,iMax
           IF ( k .EQ. kLowC(i,j,bi,bj) ) THEN
            ddRloc = rC(k)-R_low(i,j,bi,bj)
            PHIBOTfv(i,j,bi,bj) = phiHydC(i,j)
     &       + ddRloc*gravFacC(k)*gravity*alphaRho(i,j)*recip_rhoConst
           ENDIF
          ENDDO
         ENDDO

C--     end of dynamics k loop (1:Nr)
        ENDDO

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C  --  last level (bottom): rescale (r*) and add surface contribution

#ifdef NONLIN_FRSURF
        IF ( select_rStar.GE.1 .AND. nonlinFreeSurf.GE.4 ) THEN
C-    Integral of b.dr = rStarFac * Integral of b.dr* :
C- Note: dPhiRef*(rStarFacC -1) = g*H*((eta+H)/H -1) = Bo_surf*etaN
C     so that this expression is the same as before (same as in "ELSE" block below)
         DO j=jMin,jMax
          DO i=iMin,iMax
           dPhiRef = ( Ro_surf(i,j,bi,bj)-R_low(i,j,bi,bj) )
     &               *gravity
           PHIBOTfv(i,j,bi,bj) =
     &              PHIBOTfv(i,j,bi,bj)*rStarFacC(i,j,bi,bj)
     &            + dPhiRef*( rStarFacC(i,j,bi,bj) - 1. _d 0 )
     &            + phi0surf(i,j,bi,bj)
          ENDDO
         ENDDO
        ELSE
#else /* NONLIN_FRSURF */
        IF ( .TRUE. ) THEN
#endif /* NONLIN_FRSURF */

         DO j=jMin,jMax
          DO i=iMin,iMax
           PHIBOTfv(i,j,bi,bj) = PHIBOTfv(i,j,bi,bj)
     &            + Bo_surf(i,j,bi,bj)*etaN(i,j,bi,bj)
     &            + phi0surf(i,j,bi,bj)
          ENDDO
         ENDDO

        ENDIF

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C         DO j = jMin, jMax
C          DO i = iMin, iMax
C           PHIBOTfv(i,j,bi,bj) = PHIBOTfv(i,j,bi,bj)*maskInC(i,j,bi,bj)
C          ENDDO
C         ENDDO

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C-    end of bi,bj loops
       ENDDO
      ENDDO

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
       CALL DIAGNOSTICS_FILL(PHIBOTfv,'PHIBOTfv',0, 1,0,1,1,myThid)
      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

#endif /* INCLUDE_PHIBOT_FV_CODE */

      RETURN
      END
