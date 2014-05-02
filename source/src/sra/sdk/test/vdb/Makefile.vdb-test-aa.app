# $Id: Makefile.vdb-test-aa.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-test-aa
SRC = vdb-test-aa

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp wvdb wkdb vfs krypto kfg kfs kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

# CHECK_CMD =
