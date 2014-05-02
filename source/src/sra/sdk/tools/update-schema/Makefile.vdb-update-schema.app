# $Id: Makefile.vdb-update-schema.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-update-schema
SRC = update-schema

LIB = kapp wvdb wkdb vfs kurl srapath krypto kfg kfs kproc klib
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
