# $Id: Makefile.test-srapath.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-srapath
SRC = sratest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vdb kdb ksrch vfs kurl srapath kfg krypto kfs kproc ktst klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
# CHECK_COPY = data sratest.kfg
