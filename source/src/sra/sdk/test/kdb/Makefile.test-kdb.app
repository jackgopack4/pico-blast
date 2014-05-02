# $Id: Makefile.test-kdb.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-kdb
SRC = kdbtest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp kdb vfs srapath kurl krypto kfg kfs kproc ktst klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = 

