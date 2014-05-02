# $Id: Makefile.dump-blob-boundaries.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = dump-blob-boundaries
SRC = dump-blob-boundaries

LIB = kdb vfs srapath kurl krypto kfg kfs kproc klib
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
