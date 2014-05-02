# $Id: Makefile.ccextract.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = ccextract
SRC = ccextract

LIB = kapp kxfs kxml vfs kurl srapath krypto kff kfg kfs kproc klib \
      $(BZ2_LIB) $(Z_LIB)
LIBS = $(MAGIC_LIBS) $(LIBXML_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -DUSE_NCBI_SRADB \
           $(ORIG_CPPFLAGS)

REQUIRES = LIBXML MAGIC
# Linux
