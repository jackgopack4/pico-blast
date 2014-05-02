# $Id: Makefile.kcompress.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kcompress
SRC = compress

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp$(FORCE_STATIC) vfs kurl srapath krypto kfg kfs ksproc \
      klib$(FORCE_STATIC) $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
