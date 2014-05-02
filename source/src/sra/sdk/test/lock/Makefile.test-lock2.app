# $Id: Makefile.test-lock2.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-lock2
SRC = locktest2

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kfg krypto kfs kproc klib ktst$(FORCE_STATIC) \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
