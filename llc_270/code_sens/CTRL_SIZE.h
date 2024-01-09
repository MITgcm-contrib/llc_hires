C $Header: /u/gcmpack/MITgcm_contrib/gael/verification/global_oce_llc90/code/CTRL_SIZE.h,v 1.5 2015/05/26 22:44:56 gforget Exp $
C $Name:  $

c     ==================================================================
c     CTRL_SIZE.h
c     ==================================================================

#if (defined (ALLOW_GENARR2D_CONTROL) || defined (ALLOW_GENARR3D_CONTROL) || defined (ALLOW_GENTIM2D_CONTROL))

C     Generic control variable array dimension
C     ----------------------------------------
C
C     maxCtrlArr2D :: number of 2-d generic init. ctrl variables
C     maxCtrlArr3D :: number of 3-d generic init. ctrl variables
C     maxCtrlTim2D :: number of 2-d generic tim-varying ctrl variables
C     maxCtrlProc  :: number of pre-processing options per ctrl variable

      integer     maxCtrlArr2D
      parameter ( maxCtrlArr2D = 1 )

      integer     maxCtrlArr3D
      parameter ( maxCtrlArr3D = 6 )

      integer     maxCtrlTim2D
      parameter ( maxCtrlTim2D = 8 )

      integer     maxCtrlProc
      parameter ( maxCtrlProc = 3 )

#endif

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
