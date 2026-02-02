#include "SAL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
      SUBROUTINE SAL_COMPUTE_LOADING( myTime, myIter, myThid )
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C     Calculate SAL loading effect (SAL) based on input ocean bottom pressure
C     (PHLSAL), which is topography adjusted phihydlow calculated in S/R
C     SAL_COMPUTE_MASS_ANOMALY.
C     A spatial mean should be removed from PHL_SAL before using to ensure no extra
C     mass is being added to the system.  Should probably mask out the land as well.
C     
C     K.Quinn Aug 2012
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

 
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
      _RL myTime
      INTEGER myIter
      INTEGER myThid
      
C !FUNCTIONS
      INTEGER  ILNBLNK
      INTEGER  MDS_RECLEN
      EXTERNAL ILNBLNK
      EXTERNAL MDS_RECLEN

C     LOCAL VARIABLES:
      INTEGER iUnit, filePrec, length_of_rec
      CHARACTER*512 fname
      INTEGER bi, bj, i, j, ii, jj, il, jl
      INTEGER ip, im
      INTEGER lbuff
#ifdef ALLOW_EXCH2
      REAL*8  PHLSAL_global(W2_ioBufferSize)
      REAL*8  SAL_global(W2_ioBufferSize)
#else  /* ALLOW_EXCH2 */
      REAL*8  PHLSAL_global(Nx*Ny)
      REAL*8  SAL_global(Nx*Ny)
#endif /* ALLOW_EXCH2 */
#ifdef ALLOW_USE_MPI
      INTEGER ierr
#endif
      
C---Gather PHLSAL into global grid 

      _BARRIER

      _BEGIN_MASTER( mythid )

C--   apply sparse matrix

C--   contributions from this processor
      DO jl = 1,SAL_NLAT
       DO il = 1,SAL_NLON
         SAL_grid(jl,il) = 0D0
         ii = (jl-1)*SAL_NLON + il
         DO ip = SAL_M2Gindptr(ii)+1, SAL_M2Gindptr(ii+1)
          im = SAL_M2Gind(ip)
          i = MOD(im,sNx) + 1
          im = im/sNx
          j = MOD(im,sNy) + 1
          im = im/sNy
          bi = MOD(im,nSx) + 1
          bj = im/nSx + 1
          SAL_grid(jl,il) = SAL_grid(jl,il)
     &                    + SAL_M2Gwgt(ip)*PHLSAL(i,j,bi,bj)
         ENDDO
       ENDDO
      ENDDO

C--   Collect data from all procs
#ifdef ALLOW_USE_MPI
      IF ( usingMPI ) THEN
       CALL TIMER_START('SAL_REDUCE       [SAL_COMPUTE_LOADING]',myThid)
       lbuff = SAL_NLON*SAL_NLAT
       IF (myProcId .eq. 0) THEN
        CALL MPI_REDUCE( MPI_IN_PLACE, SAL_grid, lbuff,
     &         MPI_DOUBLE_PRECISION, MPI_SUM, 0, MPI_COMM_MODEL, ierr )
       ELSE
        CALL MPI_REDUCE( SAL_grid, SAL_grid, lbuff,
     &         MPI_DOUBLE_PRECISION, MPI_SUM, 0, MPI_COMM_MODEL, ierr )
       ENDIF
       CALL TIMER_STOP ('SAL_REDUCE       [SAL_COMPUTE_LOADING]',myThid)
      ENDIF
#endif

      IF (myProcId .eq. 0) THEN

       IF (SAL_diagIter.GT.0 .AND. MOD(myIter,SAL_diagIter).EQ.0) THEN
        WRITE(fname,'(A,I10.10,A)') 'SAL_grid.',myIter,'.bin'
        filePrec = 64
        CALL MDSFINDUNIT( iUnit, myThid )
        length_of_rec = MDS_RECLEN(filePrec,SAL_NLON*SAL_NLAT,myThid)
        OPEN(iUnit, file=fname, status='unknown', access='direct',
     &       recl=length_of_rec)
        WRITE(iUnit, rec=1) SAL_grid
        CLOSE(iUnit)
       ENDIF

#ifdef SAL_SKIP_GRID_CALCS
       DO j = 1,SAL_NLAT
        DO i = 1,SAL_NLON
         SAL_grid(j,i) = 0D0
        ENDDO
       ENDDO
#else
C      map mass anomaly (in SAL_grid) to spherical harmonics,
C      apply kernel, and map back to lat-long (again SAL_grid)
       CALL SAL_GRID_CALCS(myTime,myIter,myThid)
#endif

       IF (SAL_diagIter.GT.0 .AND. MOD(myIter,SAL_diagIter).EQ.0) THEN
        WRITE(fname,'(A,I10.10,A)') 'SAL_gridSAL.',myIter,'.bin'
        filePrec = 64
        CALL MDSFINDUNIT( iUnit, myThid )
        length_of_rec = MDS_RECLEN(filePrec,SAL_NLON*SAL_NLAT,myThid)
        OPEN(iUnit, file=fname, status='unknown', access='direct',
     &       recl=length_of_rec)
        WRITE(iUnit, rec=1) SAL_grid
        CLOSE(iUnit)
       ENDIF

C end process 0 if statement
      ENDIF

C--   broadcast to all processes
#ifdef ALLOW_USE_MPI
      IF ( usingMPI ) THEN
       CALL MPI_BCAST(SAL_grid,SAL_NLON*SAL_NLAT,MPI_DOUBLE_PRECISION,
     &                0,MPI_COMM_MODEL,ierr)
      ENDIF
#endif /* ALLOW_USE_MPI */

      _END_MASTER( mythid )
      _BARRIER

C---Interpolate from regular grid to model grid
      CALL SAL_LATLON2MODEL(
     I                       SAL_grid,
     O                       SAL,
     I                       XC, YC, SAL_ll2modelMethod,
     I                       myIter, myThid )

c      _BARRIER

C need to populate halo regions
      _EXCH_XY_RL(SAL, myThid)

c remove spatial mean here.  Doesn't work on halo regions
c so need another exch
C      CALL REMOVE_MEAN_RL( 1, SAL, maskInC, maskInC, rA, drF,
C     &     'SAL', 1.0, myThid )
C      _EXCH_XY_RL(SAL, myThid)

      END SUBROUTINE SAL_COMPUTE_LOADING

