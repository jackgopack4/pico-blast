# $Id: Makefile.proxy-srv.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = proxy-srv
SRC = proxy-srv

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kfg krypto kfs kproc klib
LIBS = $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_CMD =

REQUIRES = MSWin
