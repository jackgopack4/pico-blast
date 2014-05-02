# $Id: Makefile.kar.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kar
SRC = kar
LIB = kapp$(FORCE_STATIC) vfs kurl srapath kfg krypto kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
