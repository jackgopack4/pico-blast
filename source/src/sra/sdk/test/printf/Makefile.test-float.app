# $Id: Makefile.test-float.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-float
SRC = test-float

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp$(FORCE_STATIC) vfs kurl srapath kfg krypto kfs kproc klib
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
