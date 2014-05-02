# $Id: Makefile.wb-test-kfg.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = wb-test-kfg
SRC = wb-test-kfg

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp kfg vdb vfs kdb kfs krypto kproc ktst klib
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD =

