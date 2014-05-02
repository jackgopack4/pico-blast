# $Id: Makefile.wb-test-srapath.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = wb-test-srapath
SRC = wb-test-srapath

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vdb kdb vfs srapath kurl krypto kfg kfs kproc ktst klib
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
# CHECK_COPY = config.kfg
