# $Id: Makefile.fix_read_seg-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = fix_read_seg-test
SRC = fix_read_seg-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = ksrch$(DLL) ktst kapp vfs kfg krypto srapath kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

CHECK_CMD =
