# $Id: Makefile.double-VCursorCommit-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = double-VCursorCommit-test
SRC = double-VCursorCommit-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp wvdb wkdb vfs kurl srapath krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
