# $Id: Makefile.check-blob-size.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = check-blob-size
SRC = check-blob-size

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = vxf vdb kdb vfs kurl srapath kapp krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
