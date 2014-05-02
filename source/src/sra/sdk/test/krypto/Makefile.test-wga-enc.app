# $Id: Makefile.test-wga-enc.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-wga-enc
SRC = test-wga-enc

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath krypto kfg kfs kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD  =
CHECK_COPY = wga-enc
