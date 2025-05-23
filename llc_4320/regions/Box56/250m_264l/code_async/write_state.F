C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_4320/code-async/write_state.F,v 1.4 2014/03/06 03:00:39 dimitri Exp $
C $Name:  $

#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#undef  MULTIPLE_RECORD_STATE_FILES

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: WRITE_STATE

C     !INTERFACE:
      SUBROUTINE WRITE_STATE ( myTime, myIter, myThid )

C     !DESCRIPTION:
C     This is the controlling routine for writing mid-level IO.  It
C     includes code for diagnosing W and RHO for output.

C     The CPP flag (MULTIPLE_RECORD_STATE_FILES) is #define/#undefed
C     here since it is specific to this routine and very user-preference
C     specific. If #undefed (default) the state files are written as in
C     all versions prior to checkpoint32, where a file is created per
C     variable, per time and per tile. This *has* to be the default
C     because most users use this mode and all utilities and scripts
C     (diagnostic) assume this form.  It is also robust, as explained
C     below.
C
C     If #defined, subsequent snap-shots are written as records in the
C     same file (no iteration number in filenames). The main advantage
C     is fewer files.  The disadvantages are that:
C       (1) it breaks a lot of diagnostic scripts,
C       (2) for large or long problems this creates huge files,
C       (3) its an unexpected, unsolicited change in behaviour which
C           came as a surprise (in c32) and is an inconvenience to
C           several users
C       (4) it can not accomodate changing the frequency of output
C           after a pickup (this is trivial in previous method but
C           needs new code and parameters in this new method)
C
C      Known Bugs include:
C       (1) if the length of integration is not exactly an integer
C           times the output frequency then the last record written
C           (at end of integration) overwrites a previously written
C           record corresponding to an earier time. *BE WARNED*

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#ifdef ALLOW_NONHYDROSTATIC
#include "NH_VARS.h"
#endif
#ifdef ALLOW_MNC
#include "MNC_PARAMS.h"
#endif

#include "FFIELDS.h"
#include "KPP.h"
#include "SURFACE.h"

      LOGICAL  DIFFERENT_MULTIPLE
      EXTERNAL DIFFERENT_MULTIPLE
      INTEGER  IO_ERRCOUNT
      EXTERNAL IO_ERRCOUNT

C     !INPUT/OUTPUT PARAMETERS:
C     myThid - Thread number for this instance of the routine.
C     myIter - Iteration number
C     myTime - Current time of simulation ( s )
      _RL     myTime
      INTEGER myThid
      INTEGER myIter


      INTEGER UCODE
      INTEGER IFLD

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) suff
      INTEGER iRec
#ifdef ALLOW_MNC
      CHARACTER*(1) pf
#endif
      COMMON /ICOUNTER_COMM/ ICOUNTER
      INTEGER ICOUNTER
      DATA ICOUNTER /0/
CEOP

      IF (
     &     DIFFERENT_MULTIPLE(dumpFreq,myTime,deltaTClock)
     &  .OR. dumpInitAndLast.AND.( myTime.EQ.endTime .OR.
     &                             myTime.EQ.startTime  )
     &   ) THEN
        IF ( dumpFreq .EQ. 0.0 ) THEN
          iRec = 1
        ELSE
          iRec = 1 + NINT( (myTime-startTime) / dumpFreq )
        ENDIF

C       Going to really do some IO. Make everyone except master thread wait.
C       this is done within IO routines => no longer needed
c       _BARRIER

C       Write model fields
        IF (snapshot_mdsio) THEN

#ifdef MULTIPLE_RECORD_STATE_FILES

C         Write each snap-shot as a new record in one file per variable
C         - creates relatively few files but these files can become huge
          CALL WRITE_REC_XYZ_RL( 'U',  uVel,iRec,myIter,myThid)
          CALL WRITE_REC_XYZ_RL( 'V',  vVel,iRec,myIter,myThid)
          CALL WRITE_REC_XYZ_RL( 'T', theta,iRec,myIter,myThid)
          CALL WRITE_REC_XYZ_RL( 'S',  salt,iRec,myIter,myThid)
          CALL WRITE_REC_XY_RL('Eta',etaN,iRec,myIter,myThid)
          CALL WRITE_REC_XYZ_RL( 'W',wVel,iRec,myIter,myThid)
#ifdef ALLOW_NONHYDROSTATIC
          IF (nonHydroStatic) THEN
            CALL WRITE_REC_XYZ_RL( 'PNH',phi_nh,iRec,myIter,myThid)
          ENDIF
#endif /* ALLOW_NONHYDROSTATIC */
#ifdef NONLIN_FRSURF
c         CALL WRITE_REC_XYZ_RS('hFacC.',hFacC,iRec,myIter,myThid)
c         CALL WRITE_REC_XYZ_RS('hFacW.',hFacW,iRec,myIter,myThid)
c         CALL WRITE_REC_XYZ_RS('hFacS.',hFacS,iRec,myIter,myThid)
#endif /* NONLIN_FRSURF */

#else /* MULTIPLE_RECORD_STATE_FILES */

C         Write each snap-shot as a new file (original and default
C         method) -- creates many files but for large configurations is
C         easier to transfer analyse a particular snap-shots
          IF ( rwSuffixType.EQ.0 ) THEN
            WRITE(suff,'(I10.10)') myIter
          ELSE
            CALL RW_GET_SUFFIX( suff, myTime, myIter, myThid )
          ENDIF

#ifdef ALLOW_OPENAD
# ifndef ALLOW_STREAMICE
          CALL WRITE_FLD_XYZ_RL( 'U.',suff,uVel%v,myIter,myThid)
          CALL WRITE_FLD_XYZ_RL( 'V.',suff,vVel%v,myIter,myThid)
          CALL WRITE_FLD_XYZ_RL( 'T.',suff,theta%v,myIter,myThid)
          CALL WRITE_FLD_XYZ_RL( 'S.',suff,salt%v,myIter,myThid)
          CALL WRITE_FLD_XY_RL('Eta.',suff,etaN%v,myIter,myThid)
          CALL WRITE_FLD_XYZ_RL( 'W.',suff,wVel%v,myIter,myThid)
          IF ( storePhiHyd4Phys .OR. myIter.NE.nIter0 ) THEN
            CALL WRITE_FLD_XYZ_RL('PH.',suff,totPhiHyd%v,myIter,myThid)
          ENDIF
# endif
#else

          
        call timer_start('asyncio   ',myThid)
        ICOUNTER = ICOUNTER+1
        CALL beginNewEpoch(icounter,myIter,0)
        CALL ASYNCIO_WRITE_FLD_XYZ_RL('U',suff,uVel,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XYZ_RL('V',suff,vVel,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XYZ_RL('W',suff,wVel,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XYZ_RL('S',suff,salt,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XYZ_RL('T',suff,theta,iCounter,myThid)

        CALL ASYNCIO_WRITE_FLD_XY_RL('N',suff,etaN,iCounter,myThid)

!        CALL ASYNCIO_WRITE_FLD_XY_RL('B',suff,AREA,iCounter,myThid)
!        CALL ASYNCIO_WRITE_FLD_XY_RL('C',suff,HEFF,iCounter,myThid)
!        CALL ASYNCIO_WRITE_FLD_XY_RL('D',suff,HSNOW,iCounter,myThid)
!        CALL ASYNCIO_WRITE_FLD_XY_RL('E',suff,UICE,iCounter,myThid)
!        CALL ASYNCIO_WRITE_FLD_XY_RL('F',suff,VICE,iCounter,myThid)
!        CALL ASYNCIO_WRITE_FLD_XY_RL('G',suff,HSALT,iCounter,myThid)

      !!CALL ASYNCIO_WRITE_FLD_XY_RL('H',suff,etaHnm1,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('I',suff,fu,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('J',suff,fv,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('K',suff,KPPhbl,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('L',suff,saltFlux,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('M',suff,EmPmR,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('O',suff,Qnet,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('P',suff,phiHydLow,iCounter,myThid)
        CALL ASYNCIO_WRITE_FLD_XY_RL('Q',suff,Qsw,iCounter,myThid)
      !!CALL ASYNCIO_WRITE_FLD_XY_RL('R',suff,dEtaHdt,iCounter,myThid)
        call timer_stop('asyncio   ',myThid)

ch        call timer_start('as usual i/o',myThid)
ch        CALL WRITE_FLD_XYZ_RL( 'U.',suff,uVel,myIter,myThid)
ch        CALL WRITE_FLD_XYZ_RL( 'V.',suff,vVel,myIter,myThid)
ch        CALL WRITE_FLD_XYZ_RL( 'T.',suff,theta,myIter,myThid)
ch        CALL WRITE_FLD_XY_RL('Eta.',suff,etaN,myIter,myThid)
ch        call timer_stop('as usual i/o',myThid)

C!        CALL WRITE_FLD_XYZ_RL( 'S.',suff,salt,myIter,myThid)
C!        CALL WRITE_FLD_XY_RL('Eta.',suff,etaN,myIter,myThid)
C!        CALL WRITE_FLD_XYZ_RL( 'W.',suff,wVel,myIter,myThid)
C!        IF ( useDynP_inEos_Zc .OR. myIter.NE.nIter0 ) THEN
C!          CALL WRITE_FLD_XYZ_RL('PH.',suff,totPhiHyd,myIter,myThid)
C!        ENDIF
#endif

ch          IF ( fluidIsWater .AND. (myIter.NE.nIter0) ) THEN
ch            CALL WRITE_FLD_XY_RL('PHL.',suff,phiHydLow,myIter,myThid)
ch          ENDIF
#ifdef ALLOW_NONHYDROSTATIC
          IF (nonHydroStatic) THEN
            CALL WRITE_FLD_XYZ_RL( 'PNH.',suff,phi_nh,myIter,myThid )
          ENDIF
          IF ( selectNHfreeSurf.GE.1 ) THEN
            CALL WRITE_FLD_XY_RL( 'dPnh.',suff,dPhiNH,myIter,myThid )
          ENDIF
#endif /* ALLOW_NONHYDROSTATIC */
#ifdef NONLIN_FRSURF
c         CALL WRITE_FLD_XYZ_RS('hFacC.',suff,hFacC,myIter,myThid)
c         CALL WRITE_FLD_XYZ_RS('hFacW.',suff,hFacW,myIter,myThid)
c         CALL WRITE_FLD_XYZ_RS('hFacS.',suff,hFacS,myIter,myThid)
#endif /* NONLIN_FRSURF */

#endif /* MULTIPLE_RECORD_STATE_FILES */

        ENDIF

#ifdef ALLOW_MNC
        IF (useMNC .AND. snapshot_mnc) THEN

          IF ( writeBinaryPrec .EQ. precFloat64 ) THEN
            pf(1:1) = 'D'
          ELSE
            pf(1:1) = 'R'
          ENDIF

C         Write dynvars using the MNC package
          CALL MNC_CW_SET_UDIM('state', -1, myThid)
          CALL MNC_CW_RL_W_S('D','state',0,0,'T', myTime, myThid)
          CALL MNC_CW_SET_UDIM('state', 0, myThid)
          CALL MNC_CW_I_W_S('I','state',0,0,'iter', myIter, myThid)
C         CALL MNC_CW_RL_W_S('D','state',0,0,'model_time',myTime,myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'U', uVel, myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'V', vVel, myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'Temp', theta, myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'S', salt, myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'Eta', etaN, myThid)
          CALL MNC_CW_RL_W(pf,'state',0,0,'W', wVel, myThid)
          IF ( storePhiHyd4Phys .OR. myIter.NE.nIter0 ) THEN
            CALL MNC_CW_SET_UDIM('phiHyd', -1, myThid)
            CALL MNC_CW_RL_W_S('D','phiHyd',0,0,'T',myTime,myThid)
            CALL MNC_CW_SET_UDIM('phiHyd', 0, myThid)
            CALL MNC_CW_I_W_S('I','phiHyd',0,0,'iter',myIter,myThid)
            CALL MNC_CW_RL_W(pf,'phiHyd',0,0,'phiHyd',
     &           totPhiHyd, myThid)
          ENDIF
          IF ( fluidIsWater .AND. (myIter .NE. nIter0) ) THEN
            CALL MNC_CW_SET_UDIM('phiHydLow', -1, myThid)
            CALL MNC_CW_RL_W_S('D','phiHydLow',0,0,'T', myTime, myThid)
            CALL MNC_CW_SET_UDIM('phiHydLow', 0, myThid)
            CALL MNC_CW_I_W_S('I','phiHydLow',0,0,'iter',myIter,myThid)
            CALL MNC_CW_RL_W(pf,'phiHydLow',0,0,'phiHydLow',
     &           phiHydLow, myThid)
          ENDIF
#ifdef ALLOW_NONHYDROSTATIC
          IF (nonHydroStatic) THEN
            CALL MNC_CW_RL_W(pf,'state',0,0,'phi_nh',phi_nh,myThid)
          ENDIF
#endif /* ALLOW_NONHYDROSTATIC */
        ENDIF
#endif /*  ALLOW_MNC  */

      ENDIF

      RETURN
      END
