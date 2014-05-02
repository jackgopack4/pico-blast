# $Id: Makefile.srapath.app 14964 2013-03-22 01:26:49Z ucko $

WATCHERS = ucko

APP = srapath
SRC = srapath

LIB = kapp vfs srapath$(FORCE_STATIC) kurl krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

REQUIRES = -XCODE
