//
// MPI IO for MITgcm
//

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <mpi.h>


// lat-lon-cap decomposition has 13 square facets
// facetElements1D is typically 1080, or 2160, or 4320



//////////////////////////////////////////////////////////////
// These values filled in during "initSizesAndTypes()"
MPI_Datatype  fieldElementalTypeMPI;
size_t  sizeofFieldElementalType;

long int tileSizeX;
long int tileSizeY;
long int xGhosts;
long int yGhosts;

long int facetElements1D;
long int facetBytes2D;
long int facetTilesInX;
long int facetTilesInY;
long int tilesPerFacet;

long int fieldZlevelSizeInBytes;
long int tileZlevelSizeInBytes;
long int ghostedTileZlevelSizeInBytes;

// The first 7 facets all use the same style of layout; here we call
// them "section1".  The last 6 facets share a layout style, but this
// style is different than section1.  Here, we call them "section2".
MPI_Datatype  section1_ioShape2D, section2_ioShape2D;
MPI_Datatype  tileShape2D, ghostedTileShape2D;
MPI_Info  ioHints;
//////////////////////////////////////////////////////////////



int
getSizeOfMPIType(MPI_Datatype mpi_type)
{
    switch (mpi_type) {

      case MPI_INT:  case MPI_FLOAT:  case MPI_REAL4:
        return 4;
      break;

      case MPI_LONG_INT:  case MPI_DOUBLE:  case MPI_REAL8:
        return 8;
      break;

      default:
        assert(("unexpected mpi elemental type", 0));
      break;

    }
    return -1;
}



void
createMPItypes(void)
{
    // Create a type with the "shape" of a section1, 2D tile
    MPI_Type_vector(tileSizeY, tileSizeX, facetElements1D,
                    fieldElementalTypeMPI, &section1_ioShape2D);
    MPI_Type_commit(&section1_ioShape2D);

    // Create a type with the "shape" of a section2, 2D tile
    MPI_Type_vector(tileSizeY, tileSizeX, 3*facetElements1D,
                    fieldElementalTypeMPI, &section2_ioShape2D);
    MPI_Type_commit(&section2_ioShape2D);


    // Create a type that describes a 2D tile in memory
    MPI_Type_vector(tileSizeY, tileSizeX, tileSizeX,
                    fieldElementalTypeMPI, &tileShape2D);
    MPI_Type_commit(&tileShape2D);

    // Create a type that describes a 2D tile in memory with ghost-cells.
    int fullDims[2] = {tileSizeX + 2*xGhosts, tileSizeY + 2*yGhosts};
    int tileDims[2] = {tileSizeX, tileSizeY};
    int startElements[2] = {xGhosts, yGhosts};
    MPI_Type_create_subarray(2, fullDims, tileDims, startElements,
              MPI_ORDER_FORTRAN, fieldElementalTypeMPI, &ghostedTileShape2D);
    MPI_Type_commit(&ghostedTileShape2D);


    // Set up some possible hints
    MPI_Info_create(&ioHints);
    MPI_Info_set(ioHints, "collective_buffering", "true");
    char blockSize[64];
    sprintf(blockSize, "%ld", (((long)facetElements1D * 3) *
            tileSizeY) * sizeofFieldElementalType);
    MPI_Info_set(ioHints, "cb_block_size", blockSize);
}



// Somehow we acquire this info at runtime
void
initSizesAndTypes(void)
{
    /////////////////////////////////////////////
    // Fundamental values
    fieldElementalTypeMPI = MPI_DOUBLE;
    facetElements1D = 1080;
    tileSizeX = 60;
    tileSizeY = 60;
    xGhosts = 8;
    yGhosts = 8;
    /////////////////////////////////////////////

    // Derived values
    sizeofFieldElementalType = getSizeOfMPIType(fieldElementalTypeMPI);
    long int facetElements2D = ((facetElements1D) * (facetElements1D));
    facetBytes2D  = (facetElements2D * sizeofFieldElementalType);
    fieldZlevelSizeInBytes = (13*(facetBytes2D));

    facetTilesInX = ((facetElements1D)/(tileSizeX));
    facetTilesInY = ((facetElements1D)/(tileSizeY));
    tilesPerFacet = ((facetTilesInX)*(facetTilesInY));

    tileZlevelSizeInBytes = tileSizeX * tileSizeY * sizeofFieldElementalType;
    ghostedTileZlevelSizeInBytes = (tileSizeX + 2*xGhosts) *
                                   (tileSizeY + 2*yGhosts) *
                                   sizeofFieldElementalType;

    // Create the specialized type definitions
    createMPItypes();
}



void
tileIO(
  MPI_Comm comm,
  char *filename,
  MPI_Offset tileOffsetInFile,
  MPI_Datatype tileLayoutInFile,
  void *tileBuf,
  MPI_Datatype tileLayoutInMemory,
  int  writeFlag)
{
    int fileFlags;
    MPI_File fh;
    int (*MPI_IO)();

    int res,count;
    MPI_Status status;

    if (writeFlag) {
        fileFlags = MPI_MODE_WRONLY | MPI_MODE_CREATE;
        MPI_IO = MPI_File_write_all;
    } else {
        fileFlags = MPI_MODE_RDONLY;
        MPI_IO = MPI_File_read_all;
    }

    //printf("filename is %s\n",filename);

    MPI_File_open(comm, filename, fileFlags, ioHints, &fh);
    MPI_File_set_view(fh, tileOffsetInFile, fieldElementalTypeMPI,
                      tileLayoutInFile, "native", ioHints);


    // MPI_IO(fh, tileBuf, 1, tileLayoutInMemory, MPI_STATUS_IGNORE);
    res = MPI_IO(fh, tileBuf, 1, tileLayoutInMemory, &status);
    
    MPI_Get_count(&status,tileLayoutInFile,&count);

    //fprintf(stderr,"MPI: %d %d\n",res,count);

    MPI_File_close(&fh);
}



// N.B.: tileID is 1-based, not 0-based
inline int
isInSection1(int tileID)
{ return (tileID <= (7 * tilesPerFacet)); }


// N.B.: tileID is 1-based, not 0-based
long int
tileOffsetInField(int tileID)
{
    return  isInSection1(tileID) ?
((tileID -= 1),
 (((long)tileID / facetTilesInX) * tileZlevelSizeInBytes * facetTilesInX) +
 (((long)tileID % facetTilesInX) * tileSizeX * sizeofFieldElementalType))
                                 :
((tileID -= 1 + (7 * tilesPerFacet)),
 (7 * facetBytes2D) +
 ((tileID / (3*facetTilesInX)) * tileZlevelSizeInBytes * 3*facetTilesInX) +
 ((tileID % (3*facetTilesInX)) * tileSizeX * sizeofFieldElementalType));
}



void
readField(
  MPI_Comm  appComm,
  char *filename,
  MPI_Offset fieldOffsetInFile,
  void *tileBuf,
  int tileID,
  int zLevels)
{
    int writeFlag = 0;
    MPI_Comm  sectionComm = MPI_COMM_NULL;
    MPI_Datatype  section1_ioShape, section2_ioShape;
    MPI_Datatype  inMemoryShape, tileShape, ghostedTileShape;

    int inSection1 = isInSection1(tileID);
    MPI_Offset tileOffsetInFile = fieldOffsetInFile + tileOffsetInField(tileID);


    // Create a type with the "shape" of a tile in memory,
    // with the given number of z-levels.
    MPI_Type_hvector(zLevels, 1, tileZlevelSizeInBytes,
                     tileShape2D, &tileShape);
    MPI_Type_commit(&tileShape);

    // Create a type with the "shape" of a tile in memory,
    // with ghost-cells, with the given number of z-levels.
    MPI_Type_hvector(zLevels, 1, ghostedTileZlevelSizeInBytes,
                     ghostedTileShape2D, &ghostedTileShape);
    MPI_Type_commit(&ghostedTileShape);


    // choose the i/o type
    inMemoryShape = tileShape;


    // Split between section1 tiles and section2 tiles.
    // If a rank has been assigned multiple tiles, it is possible that
    // some of those tiles are in section1, and some are in section2.
    // So we have to dynamically do the comm_split each time because we
    // cannot absolutely guarentee that each rank will always be on the
    // same side of the split every time.
    MPI_Comm_split(appComm, inSection1, 0, &sectionComm);

    memset(tileBuf,-1,tileZlevelSizeInBytes*zLevels);

    if (inSection1) {

        // Create a type with the "shape" of a section1 tile
        // in the file, with the given number of z-levels.
        MPI_Type_hvector(zLevels, 1, fieldZlevelSizeInBytes,
                         section1_ioShape2D, &section1_ioShape);
        MPI_Type_commit(&section1_ioShape);

	//printf("section 1: %d -> %ld (%ld + %ld)\n",tileID,tileOffsetInFile,fieldOffsetInFile,tileOffsetInField(tileID));

        // Do the i/o
        tileIO(sectionComm, filename, tileOffsetInFile, section1_ioShape,
               tileBuf, inMemoryShape, writeFlag);
        // I believe (?) this is needed to ensure consistency when writting
        if (writeFlag)  MPI_Barrier(appComm);

        MPI_Type_free(&section1_ioShape);

    } else {

        // Create a type with the "shape" of a section2 tile
        // in the file, with the given number of z-levels.
        MPI_Type_hvector(zLevels, 1, fieldZlevelSizeInBytes,
                         section2_ioShape2D, &section2_ioShape);
        MPI_Type_commit(&section2_ioShape);

	//printf("section 2: %d -> %ld (%ld + %ld)\n",tileID,tileOffsetInFile,fieldOffsetInFile,tileOffsetInField(tileID));

        // Do the i/o
        // I believe (?) this is needed to ensure consistency when writting
        if (writeFlag)  MPI_Barrier(appComm);
        tileIO(sectionComm, filename, tileOffsetInFile, section2_ioShape,
               tileBuf, inMemoryShape, writeFlag);

        MPI_Type_free(&section2_ioShape);
    }

    /*
    if (tileID==315){
      int i;
      printf("field offset: %ld   ",fieldOffsetInFile);
      printf("tile offset: %ld    ",tileOffsetInField(tileID));
      printf("zlevels: %d     ",zLevels);
      for (i=0;i<10;++i)
	printf("%f ",((double*)tileBuf)[i]);
      printf("\n");
    }
    */

    // Clean up
    MPI_Type_free(&tileShape);
    MPI_Type_free(&ghostedTileShape);
    MPI_Comm_free(&sectionComm);
}



// Fortran interface
// This uses the "usual" method for passing Fortran strings:
// the string length is passed, by value, as an extra "hidden" argument
// after the end of the normal argument list.  So for example, this
// routine would be invoked on the Fortran side like this:
//     call readField(comm, filename, offset, tilebuf, tileid, zlevels)
// This method of passing FOrtran strings is NOT defined by the Fortran
// standard, but it is the method of choice for many compilers, including
// gcc (GNU/Linux), and icc (Intel).
//
// PLEASE NOTE that the "offset" field is of type "MPI_Offset", which
// is synonymous with the Fortran type "integer(kind=MPI_OFFSET_KIND)".
// This will typically be integer*8.  But in particular it is almost
// certainly NOT of type "default integer", which means in particular
// that you CANNOT simply pass a constant (e.g. "0") as the argument,
// since that type will be of the wrong size.
void
readfield_(
  MPI_Fint  *fortranAppComm,
  char *fortranFilename,
  int  *fieldOffsetInFileInPencils,
  void *tileBuf,
  int *tileID,
  int *zLevels,
  int filenameLength)
{
    int i;
    char namebuf[filenameLength+1];
    char *filename = namebuf;

    MPI_Offset fieldOffsetInFile = *fieldOffsetInFileInPencils * tileSizeX * sizeofFieldElementalType;

    // Translate the MPI communicator from a Fortran-style handle
    // into a C-style handle.
    MPI_Comm appComm = MPI_Comm_f2c(*fortranAppComm);

    // Translate the Fortran-style string into a C-style string
    //memset(filename, ' ', filenameLength));
    strncpy(filename, fortranFilename, filenameLength);
    for (i = filenameLength;  (i > 0) && (' ' == filename[i-1]);  --i) ;
    filename[i] = '\0';
    //while(' ' == *filename) ++filename;
    assert(strlen(filename) > 0);

    //fprintf(stderr,"%d ::%s:: %d %ld  \n",appComm,filename,filenameLength,fieldOffsetInFile);

    // Make the translated call
    readField(appComm, filename, fieldOffsetInFile, tileBuf, *tileID, *zLevels);
}



// For testing
void initsizesandtypes_(void) {initSizesAndTypes();}





/////////////////////////////////////////////////////////////
// Test case
#if 0

#define FILENAME  "./dataFile"
long int fieldOffsetInFile = 0;

void
doIO(MPI_Comm appComm)
{
    int sizeZ = 3;
    int tile1[sizeZ][tileSizeY][tileSizeX];
    int tile2[sizeZ][tileSizeY][tileSizeX];
    int ghostedTile[sizeZ][tileSizeY + 2*yGhosts][tileSizeX + 2*xGhosts];
    int tileID;
    int i,j,k;

    int  appCommSize, appCommRank;
    MPI_Comm_size(appComm, &appCommSize);
    MPI_Comm_rank(appComm, &appCommRank);

    assert((facetTilesInX * tileSizeX) == facetElements1D);
    assert((facetTilesInY * tileSizeY) == facetElements1D);

    // Ignore the dry tiles ("holes") for the moment
    if (facetTilesInX * facetTilesInY * 13 != appCommSize) {
        if (0 == appCommRank) {
            printf("Unexpected number of ranks: is %d, expected %ld\n",
                   appCommSize, facetTilesInX * facetTilesInY * 13);
        }
    }
    tileID = appCommRank + 1;

#if 0
    // Fill tile1 with distinguished values
    for (k = 0;  k < sizeZ;  ++k) {
        for (j = 0;  j < (tileSizeY + 2*yGhosts);  ++j) {
            for (i = 0;  i < (tileSizeX + 2*xGhosts);  ++i) {
                ghostedTile[k][j][i] = -appCommRank;
            }
        }
    }
    for (k = 0;  k < sizeZ;  ++k) {
        for (j = 0;  j < tileSizeY;  ++j) {
            for (i = 0;  i < tileSizeX;  ++i) {
                tile1[k][j][i] = appCommRank;
                ghostedTile[k][j+yGhosts][i+xGhosts] = appCommRank;
            }
        }
    }
#endif



if (0 == appCommRank) system("/bin/echo -n 'begin io: ' ; date ");
    readField(appComm, FILENAME, 0, ghostedTile, tileID, sizeZ);
if (0 == appCommRank) system("/bin/echo -n 'half: ' ; date ");
    readField(appComm, FILENAME, sizeZ*fieldZlevelSizeInBytes,
              ghostedTile, tileID, sizeZ);

#if 1
    for (k = 0;  k < sizeZ;  ++k) {
        for (j = 0;  j < tileSizeY;  ++j) {
            for (i = 0;  i < tileSizeX;  ++i) {
                int value = ghostedTile[k][j+yGhosts][i+xGhosts];
                if (value != appCommRank) {
                    printf("Fail: %d %d %d:  %d %d\n", k,j,i, value, appCommRank);
                    exit(1);
                }
            }
        }
    }
    if (0 == appCommRank) printf("Verification complete\n");
#endif

MPI_Barrier(appComm);
if (0 == appCommRank) system("/bin/echo -n 'finish: ' ; date ");

    MPI_Finalize();
}



int
main(int argc, char *argv[])
{
    MPI_Comm  appComm = MPI_COMM_NULL;

    MPI_Init(&argc, &argv);
    MPI_Comm_dup(MPI_COMM_WORLD, &appComm);

    initSizesAndTypes();
    doIO(appComm);

    MPI_Finalize();
    return 0;
}
#endif

