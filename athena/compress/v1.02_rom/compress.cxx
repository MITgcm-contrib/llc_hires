//
// shrink/bloat for MITgcm
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdbool.h>

#include "async_io.h"


// A few WAGs for controlling the async i/o
const int64_t blockSize = 20L * 1024L * 1024L;
const int numBuffers = 10;


int
main (int argc, char *argv[])
{
  bool doShrink;

  // Check we were invoked with a legal name and the correct number
  // of arguments
  char *name = rindex (argv[0], '/');
  name = (NULL == name) ? argv[0] : name+1;

  if (strcmp (name, "shrink") == 0) {
    if (argc != 4) {
      fprintf (stderr, "usage:  shrink  maskFile  srcFile  sinkFile\n");
      return 1;
    }
    doShrink = true;
  }
  else if (strcmp (name, "bloat") == 0) {
    if ((argc != 4) && (argc != 5)) {
      fprintf (stderr, "usage:  bloat  maskFile  srcFile  sinkFile  [round]\n");
      return 1;
    }
    doShrink = false;
  }
  else {
    fprintf (stderr, "Must be invoked as 'shrink' or 'bloat', not '%s'\n", name);
    return 1;
  }


  char *maskFile = argv[1];
  char *srcFile = argv[2];
  char *sinkFile = argv[3];
  int64_t outputFileSizeRound = 1;
  if (5 == argc) outputFileSizeRound = atol(argv[4]);
  if (outputFileSizeRound <= 0) outputFileSizeRound = 1;


  // The files are big-endian float.  We choose to treat them as
  // int32_t instead, because we don't want to have to deal either
  // with conversion, nor with accidently interpreting the big-endian
  // bit pattern as an unfortunate little-endian value (e.g. NaN).
  assert (sizeof(float) == sizeof(int32_t));

  // Open src, mask, and sink files
  int srcFD = open (srcFile, O_RDONLY);
  assert (srcFD >= 0);

  int maskFD = open (maskFile, O_RDONLY);
  assert (maskFD >= 0);

  unlink (sinkFile);
  int sinkFD = open (sinkFile, O_CREAT|O_RDWR, 0644);
  assert (sinkFD >= 0);


  // Create the input queues; this automatically starts the async reads
  void *srcQ = initInputQ (srcFD, 0, -1, numBuffers, blockSize);
  assert (srcQ != NULL);

  void *maskQ = initInputQ (maskFD, 0, -1, numBuffers, blockSize);
  assert (maskQ != NULL);


  // Create the output queue
  void *sinkQ = initOutputQ (sinkFD, 0, numBuffers, blockSize);
  assert (sinkQ != NULL);


  // Get the first set of buffers.
  ioBufferHeaderType *srcBufHdr = getNextInputBuffer (srcQ);
  assert (srcBufHdr != NULL);
  srcBufHdr->k = 0;
  srcBufHdr->n =  srcBufHdr->sizeInBytes / sizeof(int32_t);

  ioBufferHeaderType *maskBufHdr = getNextInputBuffer (maskQ);
  assert (maskBufHdr != NULL);
  maskBufHdr->k = 0;
  maskBufHdr->n = maskBufHdr->sizeInBytes / sizeof(int32_t);

  ioBufferHeaderType *sinkBufHdr = getEmptyOutputBuffer (sinkQ);
  assert (sinkBufHdr != NULL);
  sinkBufHdr->k = 0;
  sinkBufHdr->n = sinkBufHdr->maxSizeInBytes / sizeof(int32_t);


  //////////////////////////////////////////////////////////////
  // Main loop
  for (;;) {

    int32_t *mask = (int32_t*)maskBufHdr->aio.aio_buf;
    int32_t *src  = (int32_t*) srcBufHdr->aio.aio_buf;
    int32_t *sink = (int32_t*)sinkBufHdr->aio.aio_buf;

    if (doShrink) {

      // Run until we have processed all the elements from one of the buffers
      while ( (maskBufHdr->k < maskBufHdr->n) &&
              (srcBufHdr->k  < srcBufHdr->n)  &&
              (sinkBufHdr->k < sinkBufHdr->n) )
      {
        if (mask[maskBufHdr->k] != 0) sink[sinkBufHdr->k++] = src[srcBufHdr->k];
        maskBufHdr->k++;
        srcBufHdr->k++;
      }

    } else {

      // For bloat, continue until either mask buffer or sink buffer fills.
      // If packed src is exhausted, we may still need to write zeros for the
      // remaining masked-out points.
      while ( (maskBufHdr->k < maskBufHdr->n) &&
              (sinkBufHdr->k < sinkBufHdr->n) )
      {
        if (mask[maskBufHdr->k] != 0) {
          if (srcBufHdr->k >= srcBufHdr->n) {
            // Need another packed value. Try to fetch next src buffer.
            releaseInputBuffer (srcQ, srcBufHdr);
            srcBufHdr = getNextInputBuffer (srcQ);

            if (NULL == srcBufHdr) {
              fprintf(stderr,
                      "ERROR: packed src exhausted before mask nonzero pattern ended\n");
              exit(1);
            }

            srcBufHdr->k = 0;
            srcBufHdr->n = srcBufHdr->sizeInBytes / sizeof(int32_t);
            src = (int32_t*) srcBufHdr->aio.aio_buf;
          }
          sink[sinkBufHdr->k++] = src[srcBufHdr->k++];
        }
        else {
          sink[sinkBufHdr->k++] = 0;
        }
        maskBufHdr->k++;
      }
    }


    // Restock whichever buffer(s) we exhausted

    if (doShrink) {
      if (srcBufHdr->k >= srcBufHdr->n) {
        releaseInputBuffer (srcQ, srcBufHdr);
        srcBufHdr = getNextInputBuffer (srcQ);

        // If there was no more src input, then done
        if (NULL == srcBufHdr) {
          sinkBufHdr->sizeInBytes = sinkBufHdr->k * sizeof(int32_t);
          putNextOutputBuffer (sinkQ, sinkBufHdr);
          break;  // break out of Main loop
        }

        srcBufHdr->k = 0;
        srcBufHdr->n = srcBufHdr->sizeInBytes / sizeof(int32_t);
      }
    }

    if (maskBufHdr->k >= maskBufHdr->n) {
      releaseInputBuffer (maskQ, maskBufHdr);
      maskBufHdr = getNextInputBuffer (maskQ);

      // For both shrink and bloat, mask exhaustion means done.
      if (NULL == maskBufHdr) {
        if (!doShrink) {
          // For bloat, make sure no extra packed src data remains.
          if (srcBufHdr->k < srcBufHdr->n) {
            fprintf(stderr,
                    "ERROR: packed src has leftover data after mask exhausted\n");
            exit(1);
          }
          releaseInputBuffer (srcQ, srcBufHdr);
          srcBufHdr = getNextInputBuffer (srcQ);
          if (NULL != srcBufHdr) {
            fprintf(stderr,
                    "ERROR: packed src has extra buffers after mask exhausted\n");
            exit(1);
          }
        }

        sinkBufHdr->sizeInBytes = sinkBufHdr->k * sizeof(int32_t);
        putNextOutputBuffer (sinkQ, sinkBufHdr);
        break;  // break out of Main loop
      }

      maskBufHdr->k = 0;
      maskBufHdr->n = maskBufHdr->sizeInBytes / sizeof(int32_t);
    }

    if (sinkBufHdr->k >= sinkBufHdr->n) {
      sinkBufHdr->sizeInBytes = sinkBufHdr->maxSizeInBytes;
      putNextOutputBuffer (sinkQ, sinkBufHdr);
      sinkBufHdr = getEmptyOutputBuffer (sinkQ);
      assert (sinkBufHdr != NULL);
      sinkBufHdr->k = 0;
      sinkBufHdr->n = sinkBufHdr->maxSizeInBytes / sizeof(int32_t);
    }

  }
  // End Main loop
  //////////////////////////////////////////////////////////////


  // Wait until all the pending async output has actually been done
  finishPendingOutput (sinkQ);

  // If this was a "bloat" command, pad the output file with zeros up to
  // a multiple of the boundary specified by "round"
  if (!doShrink && outputFileSizeRound > 1) {
    struct stat statBuf;
    int status = fstat (sinkFD, &statBuf);
    assert (0 == status);

    int64_t desiredSize = (((statBuf.st_size - 1) / outputFileSizeRound) + 1);
    desiredSize *= outputFileSizeRound;

    if (statBuf.st_size < desiredSize) {
      ftruncate (sinkFD, desiredSize);
    }
  }


  // Exit gracefully
  cleanupInputQ (srcQ);
  cleanupInputQ (maskQ);
  cleanupOutputQ (sinkQ);
  return 0;
}
