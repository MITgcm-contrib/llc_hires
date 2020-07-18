#ifdef ALLOW_TIDES

      CHARACTER*(255) tides_orientData
      CHARACTER*(255) tides_metaKernel
      COMMON /TIDES_PARAMS_C/
     &  tides_orientData,
     &  tides_metaKernel

      _RL tides_earthRadius
      _RL tides_h2
      _RL tides_k2
      _RL tides_sunGM
      _RL tides_moonGM
      _RL tides_permC0
      _RL tides_permC1
      _RL tides_permC
      _RL aSU, aMO
      REAL*8 lonSU, latSU
      REAL*8 lonMO, latMO
      COMMON /TIDES_PARAMS_R/
     &  tides_earthRadius, tides_h2, tides_k2,
     &  tides_sunGM, tides_moonGM,
     &  tides_permC0, tides_permC1, tides_permC,
     &  aSU, aMO, lonSU, latSU, lonMO, latMO

#endif /* ALLOW_TIDES */
