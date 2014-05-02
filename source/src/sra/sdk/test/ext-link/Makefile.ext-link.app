# $Id: Makefile.ext-link.app 16076 2013-05-19 02:07:57Z ucko $

WATCHERS = ucko

APP = ext-link
SRC = ext-link

CPPFLAGS = $(SRA_INCLUDE) $(Z_INCLUDE) $(BZ2_INCLUDE) \
           $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vfs kurl srapath krypto kfg kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
