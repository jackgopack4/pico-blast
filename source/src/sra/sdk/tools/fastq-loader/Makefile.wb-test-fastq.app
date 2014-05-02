# $Id: Makefile.wb-test-fastq.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = wb-test-fastq
SRC = wb-test-fastq

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = fastqloader loader align-writer ktst kapp load wvdb wkdb vfs kurl \
       srapath kfg krypto kfs kq kproc klib judy
# leave off kq on Windows per upstream Makefile?
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
