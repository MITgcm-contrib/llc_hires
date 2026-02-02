#ifdef ALLOW_SAL
CBOP
C     !ROUTINE: SAL_FIELDS.h

C     !DESCRIPTION:
C     Contains general fields for the sal pkg.

C--   COMMON /SAL_FIELDS_R/ global arrays for the SAL package
C     PHLSALref     :: bottom pressure anomaly subtraction [m^2/s^2]
C     PHLSAL        :: adjusted bottom pressure anomaly used to calculate SAL [m^2/s^2]
C     SAL           :: Changes in bottom pressure due to SAL physics [m^2/s^2]
      COMMON /SAL_FIELDS_R/ PHLSALref,PHLSAL,SAL
      _RL PHLSALRef(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL PHLSAL(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL SAL(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

C--   COMMON /SAL_INTERP_M2G/ sparse matrix for interp model to lat-lon
C     sparse matrix in csr format:
C     SAL_M2Gwgt    :: interpolation weights
C     SAL_M2Gind    :: column indices
C     SAL_M2Gindptr :: pointers into column index array for wach row
      COMMON /SAL_INTERP_M2G/
     &      SAL_M2Gwgt,
     &      SAL_M2Gind,
     &      SAL_M2Gindptr
      REAL*8    SAL_M2Gwgt(SAL_MAXM2G)
      INTEGER*4 SAL_M2Gind(SAL_MAXM2G)
      INTEGER*4 SAL_M2Gindptr(SAL_NLON*SAL_NLAT+1)

C     SAL_NLM    :: number of complex spectral harmonics coefficients
      INTEGER SAL_NLM
      PARAMETER(SAL_NLM=(SAL_LMAX+1)*(SAL_LMAX+1)-
     &                  (SAL_LMAX*(SAL_LMAX+1))/2)

C--   COMMON /SAL_INTERN_R/ fixed-precision arrays for calling SHTns
C     SAL_grid :: array on Gaussian grid to be passed to SHTns
C     SAL_lm   :: harmonic coefficients of SAL_grid
      COMMON /SAL_INTERN_R/ SAL_grid, SAL_lm
      REAL*8 SAL_grid(SAL_NLAT, SAL_NLON)
      COMPLEX*16 SAL_lm(SAL_NLM)

CEOP
#endif /* ALLOW_SAL */
