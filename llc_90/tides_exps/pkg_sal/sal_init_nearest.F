#include "SAL_OPTIONS.h"

C-------------------------------------------------------------------------------
C     Calculate nearest neighbour interpolation weights to go between
C     model grid and regular grid needed for SAL spherical harmonics
C     Only needs to be done *once*, then weights are remembered in SAL_FIELDS.h
C
C     K.Quinn August 2012
C-------------------------------------------------------------------------------

      SUBROUTINE SAL_INIT_NEAREST(myThid)

      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#ifdef ALLOW_EXCH2
# include "W2_EXCH2_SIZE.h"
# include "W2_EXCH2_TOPOLOGY.h"
# include "W2_EXCH2_PARAMS.h"
#endif /* ALLOW_EXCH2 */
#include "EEBUFF_SCPU.h"
#include "GRID.h"
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
      _RL  salgridlat(SAL_NLAT,SAL_NLON)
      _RL  salgridlng(SAL_NLAT,SAL_NLON)
      _RL  lon_inc
      _RL  coslatg(SAL_NLAT,SAL_NLON)
      _RL  coslngg(SAL_NLAT,SAL_NLON)
      _RL  sinlatg(SAL_NLAT,SAL_NLON)
      _RL  sinlngg(SAL_NLAT,SAL_NLON)
      _RL  ddist
      _RL  m2g_dist(SAL_NLAT,SAL_NLON)
      INTEGER SALIDXM2G(SAL_NLAT,SAL_NLON,2)
      LOGICAL zeroBuff, useExch2ioLayOut
      INTEGER xSize, ySize
      INTEGER  bi,bj, i, j
      INTEGER  ij, xySize, nM2G
      INTEGER iUnit, length_of_rec
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      CHARACTER*(MAX_LEN_FNAM) fname
      INTEGER iG, jG
      INTEGER np, ip, ipo, ipstart, ill, iG1, jG1
#ifdef ALLOW_USE_MPI
      INTEGER ierr
#endif
#ifdef ALLOW_EXCH2
      INTEGER iGjLoc, jGjLoc
      INTEGER myTile
      _RL  XC_global(W2_ioBufferSize)
      _RL  YC_global(W2_ioBufferSize)
      _RL  rA_global(W2_ioBufferSize)
      _RL  coslatm(W2_ioBufferSize)
      _RL  coslngm(W2_ioBufferSize)
      _RL  sinlatm(W2_ioBufferSize)
      _RL  sinlngm(W2_ioBufferSize)
#else  /* ALLOW_EXCH2 */
      INTEGER iBase, jBase
      _RL  XC_global(Nx*Ny)
      _RL  YC_global(Nx*Ny)
      _RL  rA_global(Nx*Ny)
      _RL  coslatm(Nx*Ny)
      _RL  coslngm(Nx*Ny)
      _RL  sinlatm(Nx*Ny)
      _RL  sinlngm(Nx*Ny)
#endif /* ALLOW_EXCH2 */

C Set dimensions and flags (e.g. from mdsio_write_field.F)
      xSize = Nx
      ySize = Ny
      useExch2ioLayOut = .FALSE.
      zeroBuff = .TRUE.
#ifdef ALLOW_EXCH2
      IF ( W2_useE2ioLayOut ) THEN
         xSize = exch2_global_Nx
         ySize = exch2_global_Ny
         useExch2ioLayOut = .TRUE.
      ENDIF
#endif /* ALLOW_EXCH2 */
      xySize = xSize*ySize

      WRITE(msgBuf,'(2A)') 'SAL_INTERP_WEIGHTS:',
     &       ' computing interpolation weights'
      CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                   SQUEEZE_RIGHT,myThid)

C gather XC and YC into global model grid

      _BARRIER

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
           sharedLocBuf_r8(i,j,bi,bj) = XC(i,j,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      CALL GATHER_2D_R8(
     O                  XC_global,
     I                  sharedLocBuf_r8,
     I                  xSize, ySize,
     I                  useExch2ioLayOut,
     I                  zeroBuff,
     I                  myThid )
      _BARRIER

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
           sharedLocBuf_r8(i,j,bi,bj) = YC(i,j,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      CALL GATHER_2D_R8(
     O                  YC_global,
     I                  sharedLocBuf_r8,
     I                  xSize, ySize,
     I                  useExch2ioLayOut,
     I                  zeroBuff,
     I                  myThid )
      _BARRIER

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO j=1,sNy
         DO i=1,sNx
           sharedLocBuf_r8(i,j,bi,bj) = rA(i,j,bi,bj)
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      CALL GATHER_2D_R8(
     O                  rA_global,
     I                  sharedLocBuf_r8,
     I                  xSize, ySize,
     I                  useExch2ioLayOut,
     I                  zeroBuff,
     I                  myThid )
      _BARRIER

C Now have gathered, do everything on process 0, as per jmc

      _BEGIN_MASTER( mythid )
      IF (myProcId .eq. 0) THEN

C Set up Gaussian grid, complete in latitude and longitude of dimension (N,2N)

         lon_inc = 360 _d 0/SAL_NLON
         do i = 1,SAL_NLAT
           do j = 1,SAL_NLON
             salgridlat(i,j) = SAL_lat(i)
             salgridlng(i,j) = SAL_lon_0 + lon_inc*(j - 1 _d 0)
           enddo
         enddo

         do i = 1,SAL_NLAT
           do j = 1,SAL_NLON
             coslatg(i,j) = cos(salgridlat(i,j)*deg2rad)
             coslngg(i,j) = cos(salgridlng(i,j)*deg2rad)
             sinlatg(i,j) = sin(salgridlat(i,j)*deg2rad)
             sinlngg(i,j) = sin(salgridlng(i,j)*deg2rad)
           enddo
         enddo

         do ij = 1,xySize
           if ( rA_global(ij).GT.0 _d 0 ) then
             coslatm(ij) = cos(YC_global(ij)*deg2rad)
             coslngm(ij) = cos(XC_global(ij)*deg2rad)
             sinlatm(ij) = sin(YC_global(ij)*deg2rad)
             sinlngm(ij) = sin(XC_global(ij)*deg2rad)
           else
             coslatm(ij) = 0 _d 0
             coslngm(ij) = 0 _d 0
             sinlatm(ij) = 0 _d 0
             sinlngm(ij) = 0 _d 0
           endif
         enddo

C initialize interp weight arrays

         do i = 1,SAL_NLAT
           do j = 1,SAL_NLON
             m2g_dist(i,j) = 361 _d 0*deg2rad
             SALIDXM2G(i,j,1) = -999
             SALIDXM2G(i,j,2) = -999
           enddo
         enddo

C simple brute-force search for nearest neighbours

       WRITE(msgBuf,'(2A)') 'do i = 1,SAL_NLAT',
     &                      'do j = 1,SAL_NLON'
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
         do i = 1,SAL_NLAT
           do j = 1,SAL_NLON
       WRITE(msgBuf,'(4I5)') i,SAL_NLAT, j,SAL_NLON
       CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                    SQUEEZE_RIGHT,myThid)
             do ij = 1,xySize
                if ( rA_global(ij).GT.0. ) then
                   ddist = ACOS(sinlatg(i,j)*
     &                  sinlatm(ij) +
     &                  coslatg(i,j)*coslatm(ij) *
     &                  (coslngg(i,j)*coslngm(ij) +
     &                  sinlngg(i,j)*sinlngm(ij)) )
                else
                   ddist = 361 _d 0*deg2rad + 1 _d 0
                endif
                if (ddist .lt. m2g_dist(i,j)) then
                   m2g_dist(i,j) = ddist
                   SALIDXM2G(i,j,1) = ij
                   SALIDXM2G(i,j,2) = 1
                endif
             enddo
           enddo
         enddo

C--      convert to csr sparse matrix

C        check array size sufficient
         IF (SAL_NLON*SAL_NLAT .GT. SAL_MAXM2G) THEN
          WRITE(msgBuf,'(A,I10,A,I10,A)') 'SAL_INTERP_WEIGHTS: need',
     &    ' SAL_MAXM2G to be at least SAL_NLON*SALGRID for nearest'
          CALL PRINT_ERROR( msgBuf, myThid )
          CALL ALL_PROC_DIE( 0 )
          STOP 'ABNORMAL END: S/R SAL_INTERP_WEIGHTS (SAL_MAXM2G)'
         ENDIF

C        convert
         nM2G = 0
         DO j = 1,SAL_NLAT
          DO i = 1,SAL_NLON
           ij = (j-1)*SAL_NLON + i
           SAL_M2Gindptr(ij) = nM2G
           IF (SALIDXM2G(j,i,1) .GT. 0) THEN
            nM2G = nM2G + 1
            SAL_M2Gind(nM2G) = SALIDXM2G(j,i,1) - 1
            SAL_M2Gwgt(nM2G) = 1 _d 0
           ENDIF
          ENDDO
         ENDDO
         SAL_M2Gindptr(SAL_NLON*SAL_NLAT+1) = nM2G

         IF (nM2G .NE. SAL_NLON*SAL_NLAT) THEN
          WRITE(msgBuf,'(2A)') 'SAL_INTERP_WEIGHTS: **WARNING**',
     &          ' not all grid points set by nearest interpolation'
          CALL PRINT_MESSAGE(msgBuf,errorMessageUnit,
     &                      SQUEEZE_RIGHT,myThid)
         ENDIF

C        write to binary files
         WRITE(msgBuf,'(2A)') 'SAL_INTERP_WEIGHTS:',
     &        ' writing weights for model-to-latlon interp'
         CALL PRINT_MESSAGE(msgBuf,standardMessageUnit,
     &                      SQUEEZE_RIGHT,myThid)
         WRITE(fname,'(A)') 'SAL_model2ll_nearest_indptr.bin'
         length_of_rec = MDS_RECLEN(32,SAL_NLON*SAL_NLAT+1,myThid)
         CALL MDSFINDUNIT( iUnit, myThid )
         OPEN(iUnit, file=fname, status='unknown', access='direct',
     &        recl=length_of_rec)
         WRITE(iUnit, rec=1) SAL_M2Gindptr
         CLOSE(iUnit)

         WRITE(fname,'(A)') 'SAL_model2ll_nearest_indices.bin'
         length_of_rec = MDS_RECLEN(32,nM2G,myThid)
         CALL MDSFINDUNIT( iUnit, myThid )
         OPEN(iUnit, file=fname, status='unknown', access='direct',
     &        recl=length_of_rec)
         WRITE(iUnit, rec=1) SAL_M2Gind(1:nM2G)
         CLOSE(iUnit)

         WRITE(fname,'(A)') 'SAL_model2ll_nearest_weights.bin'
         length_of_rec = MDS_RECLEN(64,nM2G,myThid)
         CALL MDSFINDUNIT( iUnit, myThid )
         OPEN(iUnit, file=fname, status='unknown', access='direct',
     &        recl=length_of_rec)
         WRITE(iUnit, rec=1) SAL_M2Gwgt(1:nM2G)
         CLOSE(iUnit)

C end process 0 if statement
      ENDIF

#ifdef ALLOW_USE_MPI
      IF ( usingMPI ) THEN
       CALL TIMER_START('SAL_BCAST        [SAL_INIT_NEAREST]',myThid)
       CALL MPI_BCAST(SAL_M2Gindptr,SAL_NLON*SAL_NLAT+1,MPI_INTEGER,
     &                0,MPI_COMM_MODEL,ierr)
       nM2G = SAL_M2Gindptr(SAL_NLON*SAL_NLAT+1)
       CALL MPI_BCAST(SAL_M2Gind,nM2G,MPI_INTEGER,
     &                0,MPI_COMM_MODEL,ierr)
       CALL MPI_BCAST(SAL_M2Gwgt,nM2G,MPI_DOUBLE_PRECISION,
     &                0,MPI_COMM_MODEL,ierr)
       CALL TIMER_STOP ('SAL_BCAST        [SAL_INIT_NEAREST]',myThid)
      ENDIF
#endif /* ALLOW_USE_MPI */

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
