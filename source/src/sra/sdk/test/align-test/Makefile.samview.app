# $Id: Makefile.samview.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = samview
SRC = samview
# bam

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = align-access ncbi-bam vfs kurl srapath krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = -MSVC
