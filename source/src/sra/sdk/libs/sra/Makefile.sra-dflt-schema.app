# $Id: Makefile.sra-dflt-schema.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sra-dflt-schema
SRC = sra-dflt-schema

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vdb kdb vfs kurl srapath krypto kfg kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB:%=%$(STATIC)) $(BZ2_LIB:%=%$(STATIC))
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
