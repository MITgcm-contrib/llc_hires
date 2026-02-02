#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: SAL_INIT_MODEL2LL

C !INTERFACE:
      SUBROUTINE SAL_INIT_MODEL2LL(myThid)

C     !DESCRIPTION:
C     Read arrays for interpolation from model to lat-lon grid

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#ifdef ALLOW_EXCH2
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_TOPOLOGY.h"
#endif /* ALLOW_EXCH2 */
#include "SAL_SIZE.h"
#include "SAL_PARAMS.h"
#include "SAL_FIELDS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid - Thread number for this instance of the routine.
      INTEGER  myThid

C     !FUNCTIONS:
      INTEGER  ILNBLNK
      INTEGER  MDS_RECLEN
      EXTERNAL ILNBLNK
      EXTERNAL MDS_RECLEN
CEOP

C     !LOCAL VARIABLES:
      INTEGER iUnit, length_of_rec, iL, nM2G
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*(MAX_LEN_FNAM) fname
      INTEGER xSize, ySize
      LOGICAL useExch2GlobLayOut
      INTEGER j, bi, bj
      INTEGER iG, jG
      INTEGER iBase, jBase
#ifdef ALLOW_EXCH2
      INTEGER iGjLoc, jGjLoc
      INTEGER myTile
#endif /* ALLOW_EXCH2 */
      INTEGER np, ip, ipo, ipstart, ill, iG1, jG1

      _BEGIN_MASTER( mythid )

      WRITE(msgBuf,'(2A)') 'SAL_INIT_INTERP:',
     &     ' reading weights for model-to-latlon interp'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)
      iL = ILNBLNK(SAL_model2llFile)
      WRITE(fname,'(A,A)') SAL_model2llFile(1:iL), '_indptr.bin'
      length_of_rec = MDS_RECLEN(32,SAL_NLON*SAL_NLAT+1,myThid)
      CALL MDSFINDUNIT( iUnit, myThid )
      OPEN(iUnit, file=fname, status='old', access='direct',
     &     recl=length_of_rec)
      READ(iUnit, rec=1) SAL_M2Gindptr
      CLOSE(iUnit)

      nM2G = SAL_M2Gindptr(SAL_NLON*SAL_NLAT+1)
      IF (nM2G .GT. SAL_MAXM2G) THEN
       WRITE(msgBuf,'(A,I10,A,I10,A)') 'SAL_INIT_INTERP: found ',
     & nM2G,' model2ll weights, but SAL_MAXM2G = ',SAL_MAXM2G
       CALL PRINT_ERROR( msgBuf, myThid )
       WRITE(msgBuf,'(2A)') 'SAL_INIT_INTERP: ',
     &  'need to increase SAL_MAXM2G'
       CALL PRINT_ERROR( msgBuf, myThid )
       CALL ALL_PROC_DIE( 0 )
       STOP 'ABNORMAL END: S/R SAL_INIT_INTERP (SAL_MAXM2G)'
      ENDIF

      WRITE(msgBuf,'(A,I10,A)') 'SAL_INIT_INTERP: reading ',
     &                          nM2G,' model2ll weights'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)

      iL = ILNBLNK(SAL_model2llFile)
      WRITE(fname,'(A,A)') SAL_model2llFile(1:iL), '_indices.bin'
      length_of_rec = MDS_RECLEN(32,nM2G,myThid)
      CALL MDSFINDUNIT( iUnit, myThid )
      OPEN(iUnit, file=fname, status='old', access='direct',
     &     recl=length_of_rec)
      READ(iUnit, rec=1) SAL_M2Gind(1:nM2G)
      CLOSE(iUnit)

      iL = ILNBLNK(SAL_model2llFile)
      WRITE(fname,'(A,A)') SAL_model2llFile(1:iL), '_weights.bin'
      length_of_rec = MDS_RECLEN(64,nM2G,myThid)
      CALL MDSFINDUNIT( iUnit, myThid )
      OPEN(iUnit, file=fname, status='old', access='direct',
     &     recl=length_of_rec)
      READ(iUnit, rec=1) SAL_M2Gwgt(1:nM2G)
      CLOSE(iUnit)

C--   Restrict to model grid cells on this processor
C     and map to tile indices
#ifdef ALLOW_EXCH2
      xSize = exch2_global_Nx
      ySize = exch2_global_Ny
#else /* ALLOW_EXCH2 */
      xSize = Nx
      ySize = Ny
#endif /* ALLOW_EXCH2 */
      np = myProcId + 1
      ipo = 0
      DO ill=1,SAL_NLON*SAL_NLAT
        ipstart = SAL_M2Gindptr(ill) + 1
        SAL_M2Gindptr(ill) = ipo
        DO ip=ipstart,SAL_M2Gindptr(ill+1)
          jG = SAL_M2Gind(ip)/xSize + 1
          iG = MOD(SAL_M2Gind(ip), xSize) + 1

#ifdef ALLOW_EXCH2
          DO bj=1,nSy
           DO bi=1,nSx
             myTile = W2_myTileList(bi,bj)
             IF   ( exch2_mydNx(myTile) .GT. xSize ) THEN
C-           face x-size larger than glob-size : fold it
               iGjLoc = 0
               jGjLoc = exch2_mydNx(myTile) / xSize
             ELSEIF ( exch2_tNy(myTile) .GT. ySize ) THEN
C-           tile y-size larger than glob-size : make a long line
               iGjLoc = exch2_mydNx(myTile)
               jGjLoc = 0
             ELSE
C-           default (face fit into global-IO-array)
               iGjLoc = 0
               jGjLoc = 1
             ENDIF

             DO j=1,sNy
#ifdef TARGET_NEC_SX
!cdir novector
#endif
              iG1=exch2_txGlobalo(myTile)+iGjLoc*(j-1)
              jG1=exch2_tyGlobalo(myTile)+jGjLoc*(j-1)
              IF (jG.EQ.jG1 .AND. iG.GE.iG1 .AND. iG.LT.iG1+sNx) THEN
               ipo = ipo + 1
               SAL_M2Gind(ipo) = (((bj-1)*nSx+bi-1)*sNy+j-1)*sNx+iG-iG1
               SAL_M2Gwgt(ipo) = SAL_M2Gwgt(ip)
              ENDIF
             ENDDO
           ENDDO
          ENDDO

#else /* ALLOW_EXCH2 */

          iBase = 0
          jBase = 0

#ifdef ALLOW_USE_MPI
          IF (usingMPI) THEN
           iBase = mpi_myXGlobalLo(np)-1
           jBase = mpi_myYGlobalLo(np)-1
          ENDIF
#endif

          DO bj=1,nSy
           DO bi=1,nSx
             DO j=1,sNy
#ifdef TARGET_NEC_SX
!cdir novector
#endif
              iG1 = iBase+(bi-1)*sNx+1
              jG1 = jBase+(bj-1)*sNy+j
              IF (jG.EQ.jG1 .AND. iG.GE.iG1 .AND. iG.LT.iG1+sNx) THEN
               ipo = ipo + 1
               SAL_M2Gind(ipo) = (((bj-1)*nSx+bi-1)*sNy+j-1)*sNx+iG-iG1
               SAL_M2Gwgt(ipo) = SAL_M2Gwgt(ip)
              ENDIF
             ENDDO
           ENDDO
          ENDDO

#endif /* ALLOW_EXCH2 */

        ENDDO
      ENDDO
      SAL_M2Gindptr(SAL_NLON*SAL_NLAT+1) = ipo

      _END_MASTER( mythid )
      _BARRIER

      RETURN
      END
