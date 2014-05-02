# $Id: Makefile.crc32sum.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = crc32sum
SRC = crc32sum

LIB = kapp vfs kurl srapath krypto kfg kfs ksproc klib
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
