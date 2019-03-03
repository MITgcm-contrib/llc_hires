C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_90/code-async/asyncio_driver_config.F,v 1.2 2019/03/03 01:17:30 dimitri Exp $

#include "PACKAGES_CONFIG.h"


#include "CPP_EEOPTIONS.h"
#include "W2_OPTIONS.h"

      SUBROUTINE ASYNCIO_DRIVER_CONFIG( myThid )

      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "W2_EXCH2_SIZE.h"
#include "W2_EXCH2_PARAMS.h"
#include "W2_EXCH2_TOPOLOGY.h"
      INTEGER myThid

      INTEGER bi, bj

      INTEGER ASYNCIO_NXG, ASYNCIO_NYG
      INTEGER ASYNCIO_TXGLO, ASYNCIO_TYGLO
      INTEGER tN, IEND, tF, i

C     Call ASYNCIO setup
      ASYNCIO_NXG   = NX
      ASYNCIO_NYG   = NY
#ifdef ALLOW_EXCH2
      ASYNCIO_NXG   = exch2_global_Nx
      ASYNCIO_NYG   = exch2_global_Ny
#endif /* ALLOW_EXCH2 */

chenze assuming exch2

c      CALL MYASYNCIO_SET_GLOBAL_SIZES( ASYNCIO_NXG,   ASYNCIO_NYG, NR )

chenze have all compute ranks call & sort out bcast in recvTask

! Now that the C code can include SIZE.h directly, we don't
! have to do this any more
!      CALL MYASYNCIO_SET_GLOBAL_SIZES( exch2_global_Nx, exch2_global_Ny, 
!     $        Nr, exch2_nTiles, nPx, sNx, sNy, OLx, OLy )


      CALL ASYNCIO_TILE_ARRAYS(exch2_txGlobalo, exch2_tyGlobalo, 
     $     exch2_mydNx)


c      write(*,*) 'BRON ',exch2_nTiles
c      do i=1,exch2_nTiles
c         write(*,*) 'BRON ',exch2_myFace(i),exch2_mydNx(i),
c     $ exch2_mydNy(i),exch2_tNx(i),exch2_tNy(i)
c      enddo

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        ASYNCIO_TXGLO = myXGlobalLo - 1 + (bi-1)*sNx
        ASYNCIO_TYGLO = myYGlobalLo - 1 + (bj-1)*sNy
        tN = tileNo(bi,bj)                               ! which one of these do we want to use?
        tF = W2_myTileList(bi,bj)                        ! no requirement of ordinality anymore
                                                         ! needs to agree with # used in f3()

c        do iend=1,351
c           write(*,*) 'HENZE ',iend,exch2_myFace(iend),
c     $      exch2_tBasex(iend),exch2_tBasey(iend),
c     $      exch2_txGlobalo(iend),exch2_tyGlobalo(iend)
c        enddo


#ifdef ALLOW_EXCH2
        tN = W2_myTileList(bi,bj)
        ASYNCIO_TXGLO = exch2_txGlobalo( tN )
        ASYNCIO_TYGLO = exch2_tyGlobalo( tN )

c        write(*,*) 'rank ',mpimyid,' sending tile ',tN
c
c        if (mpimyid.eq.0) then
c           write(*,*) exch2_global_Nx,exch2_global_Ny, Nr
c           write(*,*) exch2_nTiles, nPx, sNx, sNy
c           do i=1,exch2_nTiles
c              write(*,*) i,exch2_txGlobalo(i),exch2_tyGlobalo(i),
c     $     exch2_mydNx(i),
c     $     exch2_global_Nx*(exch2_tyGlobalo(i)-1)+exch2_txGlobalo(i) - 1 
c           enddo
c        endif
           


#endif /* ALLOW_EXCH2 */


        CALL ASYNCIO_REGISTER_TILE( ASYNCIO_TXGLO, ASYNCIO_TYGLO, TN )  ! evidently a no-op now
ch	PRINT *, ' REGISTERING TILE ', TF
	CALL ASYNCIO_BRON_F_F2(TF)
       ENDDO
      ENDDO
      IEND=-1
      CALL ASYNCIO_BRON_F_F2(IEND)

      CALL ASYNCIO_REGISTER_FIELD_CODE(  'U'   )        ! no-op now
      CALL ASYNCIO_REGISTER_FIELD_CODE(  'V'   )        ! ...
      CALL ASYNCIO_REGISTER_FIELD_CODE(  'W'   )
      CALL ASYNCIO_REGISTER_FIELD_CODE(  'T'   )
      CALL ASYNCIO_REGISTER_FIELD_CODE(  'S'   )
      CALL ASYNCIO_REGISTER_FIELD_CODE(  'ETA' )

      RETURN
      END

