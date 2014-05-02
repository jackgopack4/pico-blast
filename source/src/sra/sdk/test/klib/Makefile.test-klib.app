# $Id: Makefile.test-klib.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-klib
SRC = test-klib

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kfg krypto kfs kproc ktst klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(Z_LIBS) $(BZ2_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD =
