# $Id: Makefile.sortreadtest.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sortreadtest
SRC = sortreadtest
LIB = wvdb wkdb kapp$(FORCE_STATIC) vfs kurl srapath krypto kfg kfs ksproc \
      klib $(Z_LIB) $(BZ2_LIB)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
