# $Id: Makefile.time-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = time-test
SRC = time-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vfs kurl srapath krypto kfg kfs kproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
