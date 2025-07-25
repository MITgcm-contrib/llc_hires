
#if 0

  The somewhat weird looking format of this file is so that it can be
  included in both C and FORTRAN routines.  The general problem is that
  FORTRAN requires that the definitions in this header file be included
  in each *subroutine*, and thus possibly multiple times in a single
  source file if that source file defines multiple subroutines, while C
  demands that the actual definitions only appear once per *file*, even
  if this header file is (accidently) #include'd multiple times.

  N.B.: Do NOT remove the parentheses in the "enum" or "PARAMETER"
  declarations.  We want the user to be able to use an expression
  in the "#define" (e.g. "#define __sNx    64 + 8 "), and not have
  to worry about precedence in the substituted expressions (e.g.
  if "__sNx" is defined as 64 + 8, then "__sNx * __sNy" would not
  behave the way you might expect, unlike "(__sNx) * (__sNy)").

#endif



#if 0
  Define the magic constants.  If you want to add (or delete) entries,
  note that the change needs to also be made to the C "enum" and the
  Fortran "parameter" statements.

    __sFacet : The fundamental unit size of a facet in llc.  Facets
               one and two are 1unit x 3units, facet three (the arctic
               polar facet) is 1unit x 1unit, and facets four and five
               are 3units x 1unit.

    __sNx, __sNy : The (sub)tile dimensions.  Each must divide __sFacet.
                   Note that if sub-tiles are being used (i.e. __nSx
                   and/or __nSy are greater than one), these dimensions
                   are the extent of each sub-tile.

    __OLx, __OLy : The overlap, i.e. the number of ghost cells.

    __nSx, __nSy : If the code uses parallel threads in (addition to MPI),
                   the sub-division of an individual tile into sub-tiles.
                   An MPI process is assigned a whole tile, and each thread
                   within that process is assigned a sub-tile.  Thus, each
                   MPI process will use (__nSx * __nSy) threads.  These
                   values are usually both "1" (i.e. no threading).

    __nPx, __nPy : The full llc decomposition of the earth contains
                     (__sFacet/__sNx) * (__sFacet/__sNy) * 13
                   total tiles.  However, some of these tiles represent
                   areas that have no water, and so MITgcm doesn't care
                   about them. (These are called "dry" tiles, or "blank"
                   tiles.)  We take that sub-set of the tiles we care
                   about (i.e. the "wet" tiles; the ones we are actually
                   going to do computations on), and imagine those tiles
                   being in a 2D array, with extent (__nPx, __nPy).
                   As a practical matter, for the llc decomposition,
                   __nPy is almost always 1 (and __nPx is equal to the
                   number of "wet" tiles).

    __Nr : The number of vertical levels in the 3D fields.
#endif

#if !defined(_MITGCM_MAGIC_CONSTANTS)
#define _MITGCM_MAGIC_CONSTANTS

#define __sFacet 90
#define __sNx    30
#define __sNy    30
#define __OLx     8
#define __OLy     8
#define __nSx     1
#define __nSy     1
#define __nPx    96
#define __nPy     1
#define __Nr     50

#endif




#if defined(__STDC__) || defined(__cplusplus)

/* For C, only include this part once */
#if !defined(SIZE_h)
#define SIZE_h

/*
** We use the "enum" hack in order to force the names into the symbol
** table, which "#define" by itself typically does not do.
*/
enum {
  sFacet = (__sFacet),
  sNx = (__sNx),
  sNy = (__sNy),
  OLx = (__OLx),
  OLy = (__OLy),
  nSx = (__nSx),
  nSy = (__nSy),
  nPx = (__nPx),
  nPy = (__nPy),
  Nr  = (__Nr),

  Nx  = ((__sNx)*(__nSx)*(__nPx)),
  Ny  = ((__sNy)*(__nSy)*(__nPy)),
  MAX_OLX  = (OLx),
  MAX_OLY  = (OLy),
};

/* end of "if !defined(SIZE_h)" */
#endif


#else


! There are no pre-processor symbols that are guaranteed to be defined
! for a Fortran compile, so we just assume that since this wasn't C/C++,
! it must be Fortran.

CBOP
C    !ROUTINE: SIZE.h
C    !INTERFACE:
C    include SIZE.h
C    !DESCRIPTION: \bv
C     *==========================================================*
C     | SIZE.h Declare size of underlying computational grid.
C     *==========================================================*
C     | The design here supports a three-dimensional model grid
C     | with indices I,J and K. The three-dimensional domain
C     | is comprised of nPx*nSx blocks (or tiles) of size sNx
C     | along the first (left-most index) axis, nPy*nSy blocks
C     | of size sNy along the second axis and one block of size
C     | Nr along the vertical (third) axis.
C     | Blocks/tiles have overlap regions of size OLx and OLy
C     | along the dimensions that are subdivided.
C     *==========================================================*
C     \ev
C
C     Voodoo numbers controlling data layout:
C     sNx :: Number of X points in tile.
C     sNy :: Number of Y points in tile.
C     OLx :: Tile overlap extent in X.
C     OLy :: Tile overlap extent in Y.
C     nSx :: Number of tiles per process in X.
C     nSy :: Number of tiles per process in Y.
C     nPx :: Number of processes to use in X.
C     nPy :: Number of processes to use in Y.
C     Nx  :: Number of points in X for the full domain.
C     Ny  :: Number of points in Y for the full domain.
C     Nr  :: Number of points in vertical direction.
CEOP
      INTEGER sFacet
      INTEGER sNx
      INTEGER sNy
      INTEGER OLx
      INTEGER OLy
      INTEGER nSx
      INTEGER nSy
      INTEGER nPx
      INTEGER nPy
      INTEGER Nx
      INTEGER Ny
      INTEGER Nr

      PARAMETER (
     &           sFacet =  (__sFacet),
     &           sNx =  (__sNx),
     &           sNy =  (__sNy),
     &           OLx =  (__OLx),
     &           OLy =  (__OLy),
     &           nSx =  (__nSx),
     &           nSy =  (__nSy),
     &           nPx =  (__nPx),
     &           nPy =  (__nPy),
     &           Nr  =  (__Nr)  )

      PARAMETER ( Nx = (__sNx)*(__nSx)*(__nPx) )
      PARAMETER ( Ny = (__sNy)*(__nSy)*(__nPy) )

C     MAX_OLX :: Set to the maximum overlap region size of any array
C     MAX_OLY    that will be exchanged. Controls the sizing of exch
C                routine buffers.
      INTEGER MAX_OLX
      INTEGER MAX_OLY
      PARAMETER ( MAX_OLX = (OLx),
     &            MAX_OLY = (OLy) )


#endif

