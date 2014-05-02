# $Id: Makefile.test-path.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-path
SRC = pathtest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vdb kdb vfs srapath kurl kfg krypto kfs kproc ktst klib judy \
      $(Z_LIB) $(BZ2_LIB)
# ksrch?
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
