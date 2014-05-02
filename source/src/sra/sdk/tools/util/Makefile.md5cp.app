# $Id: Makefile.md5cp.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = md5cp
SRC = md5cp
LIB_ = kapp vfs kurl srapath krypto kfg kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB) $(BZ2_LIB)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
