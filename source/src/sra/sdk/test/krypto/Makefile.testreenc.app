# $Id: Makefile.testreenc.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = testreenc
SRC = testreenc

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath krypto kfg kfs kproc klib ktst $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
