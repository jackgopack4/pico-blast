# $Id: Makefile.test-loader-file.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-loader-file
SRC = test-loader-file

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = load wkdb kapp vfs kurl srapath krypto kfg kfs kq kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# REQUIRES = unix
