# $Id: Makefile.md5appendtest.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = md5appendtest
SRC = md5appendtest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vfs kurl srapath krypto kfg kfs kproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = md5appendtest md5appendtest.out
