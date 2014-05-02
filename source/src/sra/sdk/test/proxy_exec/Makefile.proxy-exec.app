# $Id: Makefile.proxy-exec.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = proxy-exec
SRC = proxy-exec

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = kapp vfs kurl srapath krypto kproc kfg kfs klib
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(SRA_SDK_SYSLIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_CMD =

REQUIRES = unix
