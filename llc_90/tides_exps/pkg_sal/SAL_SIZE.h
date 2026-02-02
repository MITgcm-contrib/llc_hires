#ifdef ALLOW_SAL
CBOP
C     !ROUTINE: SAL_SIZE.h

C     !DESCRIPTION:
C     Contains grid size for sal harmonic analysis.

C     SAL_NLAT   :: number of latitudes for harmonic analysis
C     SAL_NLON   :: number of longitudes for harmonic analysis
C     SAL_LMAX   :: max degree of spherical harmonics, must be < SAL_NLAT
C     SAL_MAXM2G :: max number of sparse matrix entries for model-lat-lon interp;
C                   at least SAL_NLON*SAL_NLAT for nearest interp,
C                   larger for bilinear and bicubic
      INTEGER SAL_NLAT
      INTEGER SAL_NLON
      INTEGER SAL_LMAX
      INTEGER SAL_MAXM2G
      PARAMETER(SAL_NLAT   = 180)
      PARAMETER(SAL_NLON   = SAL_NLAT*2)
      PARAMETER(SAL_LMAX   = SAL_NLAT-1)
      PARAMETER(SAL_MAXM2G = SAL_NLON*SAL_NLAT*4)
CEOP
#endif /* ALLOW_SAL */
