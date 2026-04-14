
//
// Asynchronous read/write.  These routines present a relatively simple
// interface for streaming an input and/or output file, broken up into
// buffer-fulls.
//
// The buffers are controlled by a header:
//
// typedef struct {
//     int64_t  maxSizeInBytes;  // Size of the attached buffer
//     int64_t  sizeInBytes;     // Amount of data actually in the buffer
//     struct aiocb aio;
//     int64_t  k,n;      // Available to the user (unused by the i/o routines)
// } ioBufferHeaderType;
//
// maxSizeInBytes   The size of the allocated buffer (in bytes).  This
//                  is the size specified in the queue's "init" call.
//
// sizeInBytes   The amount of "active" data in the buffer (in bytes).
//
//               On Input, this is set by the input routines to be equal
//               to the amount read.  This will be equal to maxSizeInBytes,
//               except possibly for the very last buffer-full, which might
//               be short.
//
//               On Output, the *user* must set this field to indicate
//               how many bytes are to be written out of the buffer and
//               into the output file.  It can be any value in the range
//               [0,maxSizeInBytes] inclusive.
//
// aio   The buffer itself is pointed to by the  aio.aio_buf  field.
//       None of the other fields in the aio entry are available to
//       the user.
//
// k,n   These fields are available for the user's convenience.  They are
//       not used by the i/o routines.  They would typically be used e.g.
//       to keep track of how much of the buffer the user has already
//       processed.
//          
// The routines stream the file(s) linearly; there is no way to specify
// non-contiguous access.
//


#include <stdint.h>
#include <aio.h>




typedef struct {
    int64_t  maxSizeInBytes;  // Size of the attached buffer
    int64_t  sizeInBytes;     // Amount of data actually in the buffer
    struct aiocb aio;
    int64_t  k,n;      // Available to the user (unused by the i/o routines)
} ioBufferHeaderType;




void *
initInputQ(
  int  fd,
  int64_t fileOffset,  // Bytes to skip before starting to read
  int64_t amtToRead,   // -1 means "until the end of the file"
  int numBuffers,      // number of async xacts to have in flight
  int64_t bufferSize); // size of each xact (except possibly the last)


void *
initOutputQ(
  int  fd,
  int64_t  fileOffset,
  int numBuffers,
  int64_t bufferSize);


// When finished with an input buffer, this returns the buffer to
// the pool, and begins the next async read.
void
releaseInputBuffer(void *__q, ioBufferHeaderType *bh);


// Get the next buffer full of data from the file.
ioBufferHeaderType *
getNextInputBuffer(void *__q);


// Begin an async write of a buffer of data to the output
void
putNextOutputBuffer(void *__q, ioBufferHeaderType *bh);


// Get an empty output buffer to put data into
ioBufferHeaderType *
getEmptyOutputBuffer(void *__q);


// Wait until the pending writes have completed
void
finishPendingOutput(void *__q);


// Tear down the queue and release the memory
void
cleanupInputQ (void *__q);


// Tear down the queue and release the memory
void
cleanupOutputQ (void *__q);

