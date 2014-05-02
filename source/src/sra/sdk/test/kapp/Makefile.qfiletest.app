# $Id: Makefile.qfiletest.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = qfiletest
SRC = qfiletest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp wvdb wkdb kfg load vfs kurl srapath krypto kfg kfs kq kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = qfiletest queuefile.data
CHECK_COPY = queuefile.data
REQUIRES = unix
