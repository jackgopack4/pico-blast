# $Id: Makefile.test-kfs.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-kfs
SRC = kfstest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kfg krypto kfs kproc klib ktst $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

CHECK_CMD =
