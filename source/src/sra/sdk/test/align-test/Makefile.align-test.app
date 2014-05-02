# $Id: Makefile.align-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = align-test
SRC = align_test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = align-access ncbi-bam vfs kurl srapath krypto kapp kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
# ksrch
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
