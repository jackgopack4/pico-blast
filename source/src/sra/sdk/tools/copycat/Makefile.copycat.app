# $Id: Makefile.copycat.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = copycat
SRC = copycat ccfileformat cccat cctree cctree-dump cctar ccsra ccsubchunk \
      ccfile

LIB = kapp vfs kurl srapath kfg krypto kff kfs kproc klib $(BZ2_LIB) $(Z_LIB)
LIBS = $(MAGIC_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -DUSE_NCBI_SRADB \
           $(ORIG_CPPFLAGS)

REQUIRES = MAGIC
