# $Id: Makefile.nenctest.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = nenctest
SRC = nenctest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kryptotest kfg kfs kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = Linux GCC
