# $Id: Makefile.args-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = args-test
SRC = args-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = load kapp vfs kurl srapath krypto ktst wkdb kfg kfs kq kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
CHECK_COPY = queuefile.data
