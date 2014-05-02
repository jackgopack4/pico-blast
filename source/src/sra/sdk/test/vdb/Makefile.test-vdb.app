# $Id: Makefile.test-vdb.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-vdb
SRC = test-vdb-manager

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = vdb kdb kapp vfs srapath kurl krypto kfg kfs kproc ktst klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
