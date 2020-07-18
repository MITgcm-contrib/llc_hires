#include "TIDES_OPTIONS.h"

CBOP
C !ROUTINE: TIDES_CALC

C !INTERFACE: ==========================================================
      SUBROUTINE TIDES_CALC(
     I                     myTime, myIter, myThid )

C !DESCRIPTION:
C Calculate custom tendency terms outside k-loop in DO_OCEANIC_PHYS

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "TIDES_PARAMS.h"

C !INPUT PARAMETERS: ===================================================
C myTime    :: Current time in simulation
C myIter    :: Current time-step number
C myThid    :: my Thread Id number
      _RL     myTime
      INTEGER myIter, myThid

C !OUTPUT PARAMETERS: ==================================================
CEOP

#ifdef ALLOW_TIDES

C !FUNCTIONS: ==========================================================
      EXTERNAL MUZEN
      REAL*8   MUZEN
      EXTERNAL LEGENDRE2
      _RL      LEGENDRE2

C !LOCAL VARIABLES: ====================================================
C bi,bj     :: Tile indices
      INTEGER bi, bj, i, j
      INTEGER myDate(4)
      INTEGER yr, mon, day, ss, ld, wd, H, M, S
      CHARACTER*20 timestr
      REAL*8 time, posrec(3), rkm, lt, flat, alt, rng, rasc, dec
      REAL*8 lon, lat
      _RL muSU, muMO, rSU, rMO, xi, VSU, VMO, Vperm, cent

      _BEGIN_MASTER(myThid)

      flat = 0D0
      rkm = tides_earthRadius/1 _d 3

      CALL cal_GetDate( myIter, myTime, myDate, myThid )
      yr = myDate(1)/10000
      mon = MOD(myDate(1)/100,100)
      day = MOD(myDate(1),100)
      H = myDate(2)/10000
      M = MOD(myDate(2)/100,100)
      S = MOD(myDate(2),100)
C     convert UTC to ephemeris time using SPICE
      WRITE(timestr,'(I4,X,I2.2,X,I2.2,X,I2.2,X,I2.2,X,I2.2)'),
     &   yr, mon, day, H, M, S
      CALL STR2ET(timestr, time)

      CALL SPKPOS('SUN',time,tides_orientData,'NONE','EARTH',posrec,lt)
      CALL RECGEO(posrec,rkm,flat,lonSU,latSU,alt)
      CALL RECRAD(posrec,rng,rasc,dec)
C     convert to m
      rSU = rng*1D3
      xi = tides_earthRadius/rSU
      aSU = -tides_sunGM/rSU*(xi*xi)

      CALL SPKPOS('MOON',time,tides_orientData,'NONE','EARTH',posrec,lt)
      CALL RECGEO(posrec,rkm,flat,lonMO,latMO,alt)
      CALL RECRAD(posrec,rng,rasc,dec)
C     convert to m
      rMO = rng*1D3
      xi = tides_earthRadius/rMO
      aMO = -tides_moonGM/rMO*(xi*xi)

C     time is already relative to J2000 epoch, convert to centuries
      cent = time/36525 _d 0/86400 _d 0
      tides_permC = tides_permC0 + tides_permC1*cent

      _END_MASTER(myThid)
      _BARRIER

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=0,sNy+1
         DO i=0,sNx+1
          lon = XC(i,j,bi,bj)*deg2rad
          lat = YC(i,j,bi,bj)*deg2rad
          muSU = MUZEN(lon, lat, lonSU, latSU)
          muMO = MUZEN(lon, lat, lonMO, latMO)
          VSU = aSU*LEGENDRE2(muSU)
          VMO = aMO*LEGENDRE2(muMO)
          Vperm = tides_permC*SQRT(5 _d 0)*LEGENDRE2(SIN(lat))
          phiTide2d(i,j,bi,bj) = (1 _d 0 + tides_k2 - tides_h2)
     &                          *(VSU + VMO - Vperm)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif /* ALLOW_TIDES */

      RETURN
      END

      FUNCTION MUZEN(lon1, lat1, lon2, lat2)
      REAL*8 lon1, lat1, lon2, lat2, muzen
      MUZEN = SIN(lat1)*SIN(lat2)+COS(lat1)*COS(lat2)*COS(lon2-lon1)
      RETURN
      END

      FUNCTION LEGENDRE2(mu)
      _RL LEGENDRE2, mu
      LEGENDRE2 = 1.5 _d 0*mu*mu - 0.5 _d 0
      RETURN
      END
