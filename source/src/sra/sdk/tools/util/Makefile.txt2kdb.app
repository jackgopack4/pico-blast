# $Id: Makefile.txt2kdb.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = txt2kdb
SRC = txt2kdb
LIB_ = kapp wkdb vfs kurl srapath kfg krypto kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB:%=%$(STATIC)) $(BZ2_LIB:%=%$(STATIC))

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
