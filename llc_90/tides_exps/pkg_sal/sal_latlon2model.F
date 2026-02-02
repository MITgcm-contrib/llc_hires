#include "SAL_OPTIONS.h"
#include "EXF_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

CBOP
C     !ROUTINE: SAL_LATLON2MODEL
C     !INTERFACE:
       SUBROUTINE SAL_LATLON2MODEL(
     I                arrayin,
     O                arrayout,
     I                xG_in, yG,
     I                method, myIter, myThid )

C !DESCRIPTION: \bv
C  *==========================================================*
C  | SUBROUTINE SAL_LATLON2MODEL
C  | o Interpolate regular lat-lon input field from SHTOOLS
C  |   on to the model grid location
C  *==========================================================*
C \ev

C !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C#include "EXF_INTERP_SIZE.h"
#ifdef ALLOW_DEBUG
# include "EXF_PARAM.h"
#endif
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"

C !INPUT/OUTPUT PARAMETERS:
C  arrayin     ( _RL )   :: input field array, transposed and flipped
C  arrayout    ( _RL )   :: output array, on model grid
C     xG_in,yG           :: coordinates for output grid to interpolate to
C     method             :: 1 for bilinear; 2 for bicubic
C  myIter      (integer) :: current iteration number
C  myThid      (integer) :: My Thread Id number
      _RL     arrayin (SAL_NLAT,SAL_NLON)
      _RL     arrayout(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS     xG_in   (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS     yG      (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      INTEGER method, myIter, myThid

#ifdef ALLOW_SAL

C !FUNCTIONS:
#ifdef ALLOW_DEBUG
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK
#endif


C !LOCAL VARIABLES:
C     x_in        :: longitude vector defining input field grid
C     y_in        :: latitude  vector defining input field grid
C     lon_0              :: longitude of sw corner of global input grid
C     lon_inc            :: scalar x-grid increment
C  nxIn,nyIn   (integer) :: size in x & y direction of input file to read
C     w_ind       :: input field longitudinal index, on western side of model grid pt
C     s_ind       :: input field latitudinal index, on southern side of model grid pt
C     bi, bj      :: tile indices
C     i, j, k, l  :: loop indices
C     msgBuf      :: Informational/error message buffer
C     arrayext    :: extended input field array
      _RL      arrayext( -1:SAL_NLON+2, -1:SAL_NLAT+2 )
      _RL      x_in(-1:SAL_NLON+2), y_in(-1:SAL_NLAT+2)
      _RL      lon_0, lon_inc
      INTEGER  nxIn, nyIn
      INTEGER  w_ind(sNx,sNy), s_ind(sNx,sNy)
      INTEGER  bi, bj
      INTEGER  i, j, k, l
      INTEGER  nLoop
      _RL      tmpVar
      _RS      xG(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS      threeSixtyRS
      _RL      yPole, symSign, poleValue
      _RL      edgeFac, poleFac
      PARAMETER ( threeSixtyRS = 360. )
      PARAMETER ( yPole = 90. )
      INTEGER  nxd2
      LOGICAL  xIsPeriodic, poleSymmetry
      INTEGER  irecord
      CHARACTER*(MAX_LEN_FNAM) inFile
#ifdef ALLOW_DEBUG
      LOGICAL  debugFlag
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      _RS      prtPole(-1:4)
#endif
CEOP

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
      inFile = 'sal'
      irecord = 1

C---  Prepare input grid and input field

C--   setup input longitude grid
      nxIn = SAL_NLON
      nxd2 = SAL_NLON/2
      lon_inc = 360.0 _d 0/SAL_NLON
      lon_0 = SAL_lon_0
      DO i=-1,nxIn+2
       x_in(i) = lon_0 + (i-1)*lon_inc
      ENDDO
      xIsPeriodic = .TRUE.
      poleSymmetry = .TRUE.

C--   setup input latitude grid, flip so it goes South-North
      nyIn = SAL_NLAT
      DO j=1,nyIn
       y_in(j) = SAL_lat(SAL_NLAT+1-j)
      ENDDO
      y_in(0) = -90 _d 0
      y_in(-1)= y_in(0)*2 - y_in(1)
      y_in(nyIn+1) = 90 _d 0
      y_in(nyIn+2)= y_in(nyIn+1)*2 - y_in(nyIn)
#ifdef ALLOW_DEBUG
      DO l=-1,4
        prtPole(l) = 0.
      ENDDO
#endif
C--   For tracer (method=1,2) add 1 row @ the pole (if last row is not)
C     and will fill it with the polarmost-row zonally averaged value.
C     For vector component, cannot do much without the other component;
C     averaging properly done if uvInterp=T in S/R EXF_INTERP_UV
      IF ( method.LT.10 ) THEN
C-    Add 2 row @ southern end; if one is beyond S.pole, put one @ S.pole
       j = 0
       IF ( ABS(y_in(j+1)).LT.yPole .AND. ABS(y_in(j)).GT.yPole ) THEN
         y_in(j) = -yPole
         y_in(j-1) = -2.*yPole - y_in(j+1)
#ifdef ALLOW_DEBUG
         prtPole(j)   = 1.
         prtPole(j-1) = 2.
#endif
       ENDIF
       j = -1
       IF ( ABS(y_in(j+1)).LT.yPole .AND. ABS(y_in(j)).GT.yPole ) THEN
         y_in(j) = -yPole
#ifdef ALLOW_DEBUG
         prtPole(j)   = 1.
#endif
       ENDIF

C-    Add 2 row @ northern end; if one is beyond N.pole, put one @ N.pole
       j = nyIn+1
       IF ( ABS(y_in(j-1)).LT.yPole .AND. ABS(y_in(j)).GT.yPole ) THEN
         y_in(j) = yPole
         y_in(j+1) = 2.*yPole - y_in(j-1)
#ifdef ALLOW_DEBUG
         prtPole(3)   = 1.
         prtPole(3+1) = 2.
#endif
       ENDIF
       j = nyIn+2
       IF ( ABS(y_in(j-1)).LT.yPole .AND. ABS(y_in(j)).GT.yPole ) THEN
         y_in(j) = yPole
#ifdef ALLOW_DEBUG
         prtPole(4)   = 1.
#endif
       ENDIF
      ENDIF

C copy array, transpose and flip
      DO j=1,nyIn
       DO i=1,nxIn
        arrayext(i,j) = arrayin(nyIn+1-j,i)
       ENDDO
      ENDDO
C--   Enlarge boundary
      IF ( xIsPeriodic ) THEN
C-    fill-in added column assuming periodicity
        DO j=1,nyIn
         arrayext( 0,j)     = arrayext(nxIn  ,j)
         arrayext(-1,j)     = arrayext(nxIn-1,j)
         arrayext(nxIn+1,j) = arrayext(1,j)
         arrayext(nxIn+2,j) = arrayext(2,j)
        ENDDO
      ELSE
C-    fill-ext added column from nearest column
        DO j=1,nyIn
         arrayext( 0,j)     = arrayext(1,j)
         arrayext(-1,j)     = arrayext(1,j)
         arrayext(nxIn+1,j) = arrayext(nxIn,j)
         arrayext(nxIn+2,j) = arrayext(nxIn,j)
        ENDDO
      ENDIF
      symSign = 1. _d 0
      DO l=-1,2
       j = l
       IF ( l.GE.1 ) j = nyIn+l
       k = MAX(1,MIN(j,nyIn))
       IF ( poleSymmetry .AND. ABS(y_in(j)).GT.yPole ) THEN
        IF ( nyIn.GE.3 .AND. ABS(y_in(k)).EQ.yPole )
     &    k = MAX(2,MIN(j,nyIn-1))
C-    fill-in added row assuming pole-symmetry
        DO i=-1,nxd2
         arrayext(i,j) = symSign*arrayext(i+nxd2,k)
        ENDDO
        DO i=1,nxd2+2
         arrayext(i+nxd2,j) = symSign*arrayext(i,k)
        ENDDO
#ifdef ALLOW_DEBUG
        i = l + 2*( (l+1)/2 )
        prtPole(i) = prtPole(i) + 0.2
#endif
       ELSE
C-    fill-in added row from nearest column values
        DO i=-1,nxIn+2
         arrayext(i,j) = arrayext(i,k)
        ENDDO
       ENDIF
      ENDDO

C--   For tracer (method=1,2) set to northernmost zonal-mean value
C     at 90N to avoid sharp zonal gradients near the Pole.
C     For vector component, cannot do much without the other component;
C     averaging properly done if uvInterp=T in S/R EXF_INTERP_UV
      IF ( method.LT.10 ) THEN
       DO l=-1,4
        j = l
        IF ( l.GE.2 ) j = nyIn+l-2
        IF ( ABS(y_in(j)).EQ.yPole ) THEN
         IF (method.EQ.1 .OR. method.EQ.2) THEN
          poleValue = 0.
          DO i=1,nxIn
           poleValue = poleValue + arrayext(i,j)
          ENDDO
          poleValue = poleValue / nxIn
          DO i=-1,nxIn+2
           arrayext(i,j) = poleValue
          ENDDO
#ifdef ALLOW_DEBUG
          prtPole(l) = prtPole(l) + 0.1
#endif
         ENDIF
        ENDIF
       ENDDO
      ENDIF
      IF (method.EQ.1 .OR. method.EQ.2) THEN
C-    change first additional row from simple copy to linear interpolation
C     between nearest column values and pole value
       DO l=0,1
        k = l*(nyIn+3) -1
        IF ( ABS(y_in(k)).EQ.yPole ) THEN
         j = l*(nyIn+1)
         i = l*(nyIn-1) +1
         edgeFac = (y_in(j) - y_in(k)) / (y_in(i) - y_in(k))
         poleFac = (y_in(i) - y_in(j)) / (y_in(i) - y_in(k))
         DO i=-1,nxIn+2
           arrayext(i,j) = arrayext(i,j) * edgeFac
     &                  + arrayext(i,k) * poleFac
         ENDDO
#ifdef ALLOW_DEBUG
         prtPole(3*l) = prtPole(3*l) + 0.3
#endif
        ENDIF
       ENDDO
      ENDIF

#ifdef ALLOW_DEBUG
      debugFlag = ( debugLevel.GE.debLevC )
     &       .OR. ( debugLevel.GE.debLevB .AND. myIter.LE.nIter0 )
C     prtPole(l)=0 : extended, =1 : changed to pole, =2 : changed to symetric
      IF ( debugFlag ) THEN
        l = ILNBLNK(inFile)
        _BEGIN_MASTER(myThid)
        WRITE(msgBuf,'(3A,I6,A,2L5)')
     &   ' SAL_INTERP: file="',inFile(1:l),'", rec=', irecord,
     &   ' , x-Per,P.Sym=', xIsPeriodic, poleSymmetry
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(2A,3F4.1,A,3F12.6)') ' S.edge (j=-1,0,1) :',
     &   ' proc=', (prtPole(j),j=-1,1), ', yIn=', (y_in(j),j=-1,1)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(2A,3F4.1,A,3F12.6)') ' N.edge (j=+0,+1,+2)',
     &   ' proc=', (prtPole(j),j=2,4), ', yIn=',(y_in(j),j=nyIn,nyIn+2)
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                      SQUEEZE_RIGHT, myThid )
        _END_MASTER(myThid)
      ENDIF
#endif /* ALLOW_DEBUG */

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C---  Prepare output grid and interpolate for each tile

C--   put xG in interval [ lon_0 , lon_0+360 [
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          xG(i,j,bi,bj) = xG_in(i,j,bi,bj)-lon_0
     &                  + threeSixtyRS*2.
          xG(i,j,bi,bj) = lon_0+MOD(xG(i,j,bi,bj),threeSixtyRS)
         ENDDO
        ENDDO
#ifdef ALLOW_DEBUG
C--   Check validity of input/output coordinates
        IF ( debugFlag ) THEN
         DO j=1,sNy
          DO i=1,sNx
           IF ( xG(i,j,bi,bj) .LT. x_in(0)        .OR.
     &          xG(i,j,bi,bj) .GE. x_in(nxIn+1)   .OR.
     &          yG(i,j,bi,bj) .LT. y_in(0)        .OR.
     &          yG(i,j,bi,bj) .GE. y_in(nyIn+1) ) THEN
            l = ILNBLNK(inFile)
            WRITE(msgBuf,'(3A,I6)')
     &        'SAL_INTERP: file="', inFile(1:l), '", rec=', irecord
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A)')
     &        'SAL_INTERP: input grid must encompass output grid.'
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,2I8,2I6,A,1P2E14.6)') 'i,j,bi,bj=',
     &        i,j,bi,bj, ' , xG,yG=', xG(i,j,bi,bj), yG(i,j,bi,bj)
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,I9,A,1P2E14.6)') 'nxIn=', nxIn,
     &        ' , x_in(0,nxIn+1)=', x_in(0) ,x_in(nxIn+1)
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,I9,A,1P2E14.6)') 'nyIn=', nyIn,
     &        ' , y_in(0,nyIn+1)=', y_in(0) ,y_in(nyIn+1)
            CALL PRINT_ERROR( msgBuf, myThid )
            STOP 'ABNORMAL END: S/R SAL_INTERP'
           ENDIF
          ENDDO
         ENDDO
        ENDIF
#endif /* ALLOW_DEBUG */
       ENDDO
      ENDDO

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)

C--   Compute interpolation lon & lat index mapping
C--     latitude index
        DO j=1,sNy
         DO i=1,sNx
          s_ind(i,j) = 0
          w_ind(i,j) = nyIn+1
         ENDDO
        ENDDO
C       # of pts = nyIn+2 ; # of interval = nyIn+1 ; evaluate nLoop as
C       1 + truncated log2(# interval -1); add epsil=1.e-3 for safey
        tmpVar = nyIn + 1. _d -3
        nLoop = 1 + INT( LOG(tmpVar)/LOG(2. _d 0) )
        DO l=1,nLoop
         DO j=1,sNy
          DO i=1,sNx
           IF ( w_ind(i,j).GT.s_ind(i,j)+1 ) THEN
            k = NINT( (s_ind(i,j)+w_ind(i,j))*0.5 )
            IF ( yG(i,j,bi,bj) .LT. y_in(k) ) THEN
              w_ind(i,j) = k
            ELSE
              s_ind(i,j) = k
            ENDIF
           ENDIF
          ENDDO
         ENDDO
        ENDDO
#ifdef ALLOW_DEBUG
        IF ( debugFlag ) THEN
C-      Check that we found the right lat. index
         DO j=1,sNy
          DO i=1,sNx
           IF ( w_ind(i,j).NE.s_ind(i,j)+1 ) THEN
            l = ILNBLNK(inFile)
            WRITE(msgBuf,'(3A,I4,A,I4)')
     &        'SAL_INTERP: file="', inFile(1:l), '", rec=', irecord,
     &        ', nLoop=', nLoop
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A)')
     &        'SAL_INTERP: did not find Latitude index for grid-pt:'
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,2I8,2I6,A,1PE16.8)')
     &        'SAL_INTERP: i,j,bi,bj=',i,j,bi,bj,' , yG=',yG(i,j,bi,bj)
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,I8,A,1PE16.8)')
     &        'SAL_INTERP: s_ind=',s_ind(i,j),', lat=',y_in(s_ind(i,j))
            CALL PRINT_ERROR( msgBuf, myThid )
            WRITE(msgBuf,'(A,I8,A,1PE16.8)')
     &        'SAL_INTERP: n_ind=',w_ind(i,j),', lat=',y_in(w_ind(i,j))
            CALL PRINT_ERROR( msgBuf, myThid )
            STOP 'ABNORMAL END: S/R SAL_INTERP'
           ENDIF
          ENDDO
         ENDDO
        ENDIF
#endif /* ALLOW_DEBUG */
C--     longitude index
        DO j=1,sNy
         DO i=1,sNx
           w_ind(i,j) = INT((xG(i,j,bi,bj)-x_in(-1))/lon_inc) - 1
         ENDDO
        ENDDO

C--   Do interpolation using lon & lat index mapping
        CALL EXF_INTERPOLATE(
     I                inFile, irecord, method,
     I                nxIn, nyIn, x_in, y_in,
     I                arrayext,
     O                arrayout,
     I                xG, yG,
     I                w_ind, s_ind,
     I                bi, bj, myThid )

C      end bi,bj loops
       ENDDO
      ENDDO

#endif /* ALLOW_SAL */

      RETURN
      END
