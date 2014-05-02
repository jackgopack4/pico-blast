# $Id: Makefile.test-xfs.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-xfs1
SRC = test-xfs

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kxfs kxml kapp vfs kurl srapath krypto kfg kfs ksproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(LIBXML_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = 
CHECK_COPY = test-xfs
