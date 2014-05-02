# $Id: Makefile.SRR574828-crash-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = SRR574828-crash-test
SRC = SRR574828-crash-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vdb kdb vfs kurl srapath krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
# CHECK_REQUIRES = -Darwin -MSWin
