# $Id: Makefile.rowwritetest.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = rowwritetest
SRC = rowwritetest
LIB_ = wvdb wkdb vfs kurl srapath krypto kapp kfg kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB:%=%$(STATIC)) $(BZ2_LIB:%=%$(STATIC))

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
