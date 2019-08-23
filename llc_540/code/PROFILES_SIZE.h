C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_540/code/Attic/PROFILES_SIZE.h,v 1.1 2019/08/23 18:19:49 zhc Exp $
C $Name:  $

C============================================================
C NOBSGLOB            :: maximum number of profiles per file and tile
C NFILESPROFMAX       :: maximum number of files
C NVARMAX             :: maximum number of variables 
C NLEVELMAX           :: maximum number of vertical levels 
C NUM_INTERP_POINTS   :: number of points used in horizontal averaging
C============================================================

      INTEGER  NOBSGLOB
      PARAMETER ( NOBSGLOB = 200000  )
      INTEGER NFILESPROFMAX
      PARAMETER ( NFILESPROFMAX=20 )
      INTEGER NVARMAX
      PARAMETER ( NVARMAX=6 )
      INTEGER NLEVELMAX
      PARAMETER ( NLEVELMAX=110 )
      INTEGER NUM_INTERP_POINTS
      PARAMETER (NUM_INTERP_POINTS = 4)

