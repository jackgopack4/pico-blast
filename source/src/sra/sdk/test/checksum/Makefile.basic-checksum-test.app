# $Id: Makefile.basic-checksum-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = basic-checksum-test
SRC = basic-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp$(FORCE_STATIC) vfs kurl srapath krypto kfg kfs ksproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
CHECK_COPY = basic-test.c
