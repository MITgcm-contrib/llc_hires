
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

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <aio.h>
#include <assert.h>
#include <errno.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <vector>
#include <deque>
using namespace std;

#include "async_io.h"


#define DIE_IF(expr) { if (expr) {perror( # expr ) ; exit(1);} }


typedef struct {
    int checkWord;  // MUST be first item in struct
    int fd;
    int numChunks;
    int nextChunk;
    int64_t normalChunkSize;
    int64_t lastChunkSize;
    int64_t nextFileOffset;
    deque <ioBufferHeaderType *> pending;
    deque <ioBufferHeaderType *> available;
} inQueueHeaderType;


typedef struct {
    int checkWord;  // MUST be first item in struct
    int fd;
    int64_t bufSize;
    int64_t nextFileOffset;
    deque <ioBufferHeaderType *> pending;
    deque <ioBufferHeaderType *> available;
} outQueueHeaderType;


const int inQCheckWordValue  = 1111;
const int outQCheckWordValue = 2222;




// Remove the front element of a queue/deque and return it
inline ioBufferHeaderType *
POP(deque <ioBufferHeaderType *>  &q)
{
    ioBufferHeaderType *bh = q.front();
    q.pop_front();
    return bh;
}



// Print some stats if desired
static int64_t numIOs = 0;
static int64_t numIOwaits = 0;

void
initIOCounts(void) {numIOs = 0; numIOwaits = 0;}
void
printIOCounts(void)
{printf(" %ld i/o waits out of %ld total i/o's\n", numIOwaits, numIOs);}



void
completeAIO(struct aiocb *aio)
{
    // Wait for the given aio to complete, and verify it completed correctly
    // Hack: punt on trying to recover from EINTR

    int64_t  rtnVal;
    errno = 0;

    rtnVal = aio_error(aio);

    DIE_IF((0 != rtnVal) && (EINPROGRESS != rtnVal));

    if (EINPROGRESS == rtnVal) {
        ++numIOwaits;
        DIE_IF(aio_suspend(&aio, 1, NULL) < 0);

        // Die if the aio request did not in fact complete
        DIE_IF(aio_error(aio) != 0);
    }

    // Die if the i/o failed
    DIE_IF((rtnVal = aio_return(aio)) < 0);

    // Die if the i/o was not completely successful
    DIE_IF(rtnVal != aio->aio_nbytes);

    // I guess it must have worked
    ++numIOs;
}



void
releaseInputBuffer(void *__q, ioBufferHeaderType *bh)
{
    // If there is more input for this queue, use this released buffer
    // to initiate a read, and put it into the "pending" queue.  If there
    // is no more input, just put the buffer in the "available" queue.
    inQueueHeaderType *q = (inQueueHeaderType *)__q;
    assert (inQCheckWordValue == q->checkWord);

    if (q->nextChunk < q->numChunks) {
        q->nextChunk += 1;
        bh->aio.aio_nbytes = (q->nextChunk < q->numChunks) ?
                              q->normalChunkSize : q->lastChunkSize;
        bh->aio.aio_offset = q->nextFileOffset;
        q->nextFileOffset += bh->aio.aio_nbytes;
        DIE_IF(aio_read(&(bh->aio)) < 0);
        q->pending.push_back(bh);
    }
    else {
        q->available.push_back(bh);
    }
}





void *
initInputQ(
  int  fd,
  int64_t fileOffset,
  int64_t amtToRead,
  int numBuffers,
  int64_t bufferSize)
{
    // Validity checks
    assert(fileOffset >= 0);
    assert(numBuffers >= 2);
    assert(bufferSize > 0);

    // Get the size of the file
    struct stat statBuf;
    DIE_IF (fstat (fd, &statBuf) != 0);
    off_t fileSize = statBuf.st_size;

    // If amtToRead is -1, read to the end of the file.  Otherwise,
    // check to be sure the file is big enough to read that amount.
    if (amtToRead < 0) {
        amtToRead = fileSize - fileOffset;
    }
    else {
        assert (fileSize >= fileOffset + amtToRead);
    }

    // Break up amtToRead into bufferSize chunks, with the last chunk
    // possibly being short (and possibly not).
    int numChunks = ((amtToRead - 1) / bufferSize) + 1;
    int64_t lastChunkSize = amtToRead % bufferSize;
    if (0 == lastChunkSize) lastChunkSize = bufferSize;


    //////////////////////////////////////////////////////////////
    // Allocate and initialize the queue header
    inQueueHeaderType *q = new inQueueHeaderType;
    q->checkWord = inQCheckWordValue;
    q->fd = fd;
    q->numChunks = numChunks;
    q->nextChunk = 0;
    q->normalChunkSize = bufferSize;
    q->lastChunkSize = lastChunkSize;
    q->nextFileOffset = fileOffset;
    q->pending.clear();
    q->available.clear();

    //////////////////////////////////////////////////////////////
    // Allocate and initialize the buffers
    for (int i = 0;  i < numBuffers;  ++i) {
        ioBufferHeaderType *bh = new ioBufferHeaderType;

        bh->maxSizeInBytes = bufferSize;
        bh->sizeInBytes = 0;
        bh->k = 0;
        bh->n = 0;

        (void)memset(&(bh->aio), 0, sizeof(bh->aio));
        bh->aio.aio_fildes = fd;
        bh->aio.aio_buf = (void *) new char[bufferSize];

        // Initiate a read for this buffer, and put it in the
        // "pending" queue.
        releaseInputBuffer (q, bh);
    }

    return q;
}




void *
initOutputQ(
  int  fd,
  int64_t  fileOffset,
  int numBuffers,
  int64_t bufferSize)
{
    ///////////////////////////////////////////////////////
    // Validity checks
    assert(fileOffset >= 0);
    assert(numBuffers >= 2);
    assert(bufferSize > 0);

    ///////////////////////////////////////////////////////
    // Allocate and initialize the queue header
    outQueueHeaderType *q = new outQueueHeaderType;
    q->checkWord = outQCheckWordValue;
    q->fd = fd;
    q->bufSize = bufferSize;
    q->nextFileOffset = fileOffset;
    q->pending.clear();
    q->available.clear();

    // Setup the output headers, but don't do anything with them (yet)
    for (int i = 0;  i < numBuffers;  ++i) {
        ioBufferHeaderType *bh = new ioBufferHeaderType;

        bh->maxSizeInBytes = bufferSize;
        bh->sizeInBytes = 0;
        bh->k = 0;
        bh->n = 0;

        (void)memset(&(bh->aio), 0, sizeof(bh->aio));
        bh->aio.aio_fildes = fd;
        bh->aio.aio_buf = (void *) new char[bufferSize];

        q->available.push_back(bh);
    }

    return q;
}



ioBufferHeaderType *
getNextInputBuffer(void *__q)
{
    inQueueHeaderType *q = (inQueueHeaderType *)__q;
    assert (inQCheckWordValue == q->checkWord);

    // If no input is pending, check that we are in fact done
    if (q->pending.size() == 0) {
      assert (q->nextChunk >= q->numChunks);
      // The above assert can fail e.g. if the user doesn't create enough
      // buffers to allow at least one extra to be pending.
      return NULL;  // no more input
    }

    // Pop the head of the pending queue, and wait for it to complete
    ioBufferHeaderType *bh = POP(q->pending);
    completeAIO(&(bh->aio));

    bh->sizeInBytes = bh->aio.aio_nbytes;
    return bh;
}



void
putNextOutputBuffer(void *__q, ioBufferHeaderType *bh)
{
    outQueueHeaderType *q = (outQueueHeaderType *)__q;
    assert (outQCheckWordValue == q->checkWord);

    assert ((bh->sizeInBytes >= 0) && (bh->sizeInBytes <= bh->maxSizeInBytes));

    bh->aio.aio_nbytes = bh->sizeInBytes;
    bh->aio.aio_offset = q->nextFileOffset;

    DIE_IF(aio_write(&(bh->aio)) < 0);

    q->nextFileOffset += bh->sizeInBytes;
    q->pending.push_back(bh);
}


ioBufferHeaderType *
getEmptyOutputBuffer(void *__q)
{
    outQueueHeaderType *q = (outQueueHeaderType *) __q;
    assert (outQCheckWordValue == q->checkWord);

    ioBufferHeaderType *bh;

    // If there are empty buffer(s) already available, use one of those.
    if (q->available.size() > 0) {
        // Use an empty buffer
        bh = POP(q->available);
    }
    else {

        // Otherwise, wait for the head of the pending queue to complete
        bh = POP(q->pending);
        completeAIO(&(bh->aio));
    }

    bh->sizeInBytes = bh->k = bh->n = 0;
    return bh;
}


// Complete any pending asynch output
void
finishPendingOutput(void *__q)
{
    outQueueHeaderType *q = (outQueueHeaderType *) __q;
    assert (outQCheckWordValue == q->checkWord);

    while (q->pending.size() > 0) {
        ioBufferHeaderType *bh = POP(q->pending);
        completeAIO(&(bh->aio));
        q->available.push_back(bh);
    }
}


void
cleanupInputQ (void *__q)
{
    inQueueHeaderType *q = (inQueueHeaderType *)__q;
    assert (inQCheckWordValue == q->checkWord);

    while (q->pending.size() > 0) {
        // We should probably cancel (rather than complete) pending input
        ioBufferHeaderType *bh = POP(q->pending);
        completeAIO(&(bh->aio));
        q->available.push_back(bh);
    }

    while (q->available.size() > 0) {
        ioBufferHeaderType *bh = POP(q->available);
        delete [] (char*) bh->aio.aio_buf;
        delete bh;
    }

    delete q;
}


void
cleanupOutputQ (void *__q)
{
    outQueueHeaderType *q = (outQueueHeaderType *) __q;
    assert (outQCheckWordValue == q->checkWord);

    finishPendingOutput(q);

    while (q->available.size() > 0) {
        ioBufferHeaderType *bh = POP(q->available);
        delete [] (char*) bh->aio.aio_buf;
        delete bh;
    }

    delete q;
}


