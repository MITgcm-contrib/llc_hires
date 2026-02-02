#ifdef ALLOW_SAL
CBOP
C     !ROUTINE: SAL_PARAMS.h

C     !DESCRIPTION:
C     Contains general parameters for the sal pkg.

      INTEGER SAL_MAXNLOVE
      PARAMETER(SAL_MAXNLOVE = SAL_LMAX+1)

C     SAL_hLove     :: array of load Love numbers h
C     SAL_lLove     :: array of load Love numbers l
C     SAL_kLove     :: array of load Love numbers k
C     SAL_startTime :: when to start applying SAL effects (seconds since baseTime)
C     SAL_rhoEarth  :: mean density of the Earth (kg/m^3)
C     SAL_lon_0     :: starting longitude of grid for harmonic analysis (degrees East)
C     SAL_lat       :: latitudes of grid for harmonic analysis (degrees North)
C     SAL_wgt       :: Integration weights of Gaussian intermediate grid;
C                      Only used for logging
      COMMON /SAL_R/ 
     &               SAL_hLove, SAL_lLove, SAL_kLove,
     &               SAL_startTime, SAL_rhoEarth, SAL_lon_0, SAL_lat,
     &               SAL_wgt
      _RL SAL_hLove(SAL_MAXNLOVE)
      _RL SAL_lLove(SAL_MAXNLOVE)
      _RL SAL_kLove(SAL_MAXNLOVE)
      _RL SAL_startTime
      _RL SAL_rhoEarth
      _RL SAL_lon_0
      _RL SAL_lat(SAL_NLAT)
      _RL SAL_wgt((SAL_NLAT+1)/2)

C     SAL_diagIter       :: iterations between lat-lon SAL debug diags (0: no diagnostics)
C     SAL_cilmIter       :: iterations between spectral SAL debug diags (0: no diagnostics)
C     SAL_ll2modelMethod :: method for interpolating back to model grid: 1 means bilinear, 2 bicubic
      COMMON /SAL_I/ SAL_ll2modelMethod, SAL_diagIter, SAL_cilmIter
      INTEGER SAL_ll2modelMethod
      INTEGER SAL_diagIter
      INTEGER SAL_cilmIter

C     SAL_usePhiHydLow :: use phiHydLow from previous timestep instead of PHIBOTfv
C     SAL_maskLand     :: exclude land from mass anomaly computation
C     SAL_loadSaveCfg  :: load SHTns configuration from files shtns_cfg and shtns_cfg_fftw;
C                         create files if not found
      COMMON /SAL_L/ SAL_usePhiHydLow, SAL_maskLand, SAL_loadSaveCfg
      LOGICAL SAL_usePhiHydLow
      LOGICAL SAL_maskLand
      LOGICAL SAL_loadSaveCfg

C     SAL_LoveFile     :: path to text file with load Love numbers
C     SAL_refFile      :: path to binary file with reference bottom pressure anomaly
C     SAL_model2llFile :: path prefix for files with interpolation weights and indices
C                         from model grid to intermediate lat-long grid for SHTns
      COMMON /SAL_C/
     &   SAL_LoveFile, SAL_refFile, SAL_model2llFile
      CHARACTER*(MAX_LEN_FNAM) SAL_LoveFile
      CHARACTER*(MAX_LEN_FNAM) SAL_refFile
      CHARACTER*(MAX_LEN_FNAM) SAL_model2llFile

CEOP
#endif /* ALLOW_SAL */
