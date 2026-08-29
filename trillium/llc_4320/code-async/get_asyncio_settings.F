
!!
!! Routine to read a couple of values out of a COMMON block, and return
!! them to a 'C' routine.  In theory the C routine could dig these
!! values out of the COMMON block by itself, but in practice it is
!! incredibly annoying, especially since the standard does not define
!! exactly how fortran character strings are laid out in a COMMON block
!! and so any such solution would be implementation dependent.
!! 
!! There is also no standard conforming way to specify a 1 byte integer
!! (i.e. a C char value) in Fortran.  INTEGER*1 is supported by most
!! Fortran compilers, but it is not standard.  INTEGER(KIND=1) is
!! a 1-byte integer for most compilers, but in fact the meaning of the
!! KIND argument is not specified by the standard, so it is not
!! guarenteed.  We side-step this issue by using the default INTEGER
!! type, and implicitly assume that the default integer in Fortran is
!! the same size as the default integer in C.  I am not aware of any
!! compilers where this is not true.
!!
!! There is also no guarenteed standard for the actual bitwise
!! representation of .TRUE. and .FALSE.  So again we side-step this
!! by using default integer types.
!! 
      SUBROUTINE GET_ASYNCIO_SETTINGS (
     O   compress2D, compress3D, uncompress2D, uncompress3D, topLevel,
     I   maskDir)
      IMPLICIT NONE
#include "SIZE.h"
#include "CPP_EEMACROS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

      INTEGER compress2D, compress3D
      INTEGER uncompress2D, uncompress3D
      INTEGER topLevel
      INTEGER maskDir(*)

      character*(MAX_LEN_FNAM) tmpMaskDir
      INTEGER ii, length

      if (asyncio_2Dcompressed) then
          compress2D = 1; else; compress2D = 0; endif
      if (asyncio_3Dcompressed) then
          compress3D = 1; else; compress3D = 0; endif
      if (asyncio_2Duncompressed) then
          uncompress2D = 1; else; uncompress2D = 0; endif
      if (asyncio_3Duncompressed) then
          uncompress3D = 1; else; uncompress3D = 0; endif
      if (asyncio_3DtopLevel) then
          topLevel = 1; else; topLevel = 0; endif

      tmpMaskDir = adjustl (asyncio_maskDir)
      length = len (trim (tmpMaskDir))
      do ii = 1, length
          maskDir(ii) = ICHAR(tmpMaskDir(ii:ii))
      enddo
      maskDir(length+1) = 0;

      return
      end



#if 0
!! local hack for testing only - do not use in production!
      subroutine set_asyncio_settings
      IMPLICIT NONE
#include "SIZE.h"
#include "CPP_EEMACROS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
      asyncio_2Dcompressed   = .true.
      asyncio_3Dcompressed   = .true.
      asyncio_2Duncompressed = .true.
      asyncio_3Duncompressed = .true.
      asyncio_3DtopLevel     = .true.
      asyncio_maskDir = "./"

      return
      end
#endif

