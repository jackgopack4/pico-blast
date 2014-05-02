# $Id: Makefile.rcexplain.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = rcexplain
SRC = rcexplain
LIB_ = kapp vfs kurl srapath krypto kfg kfs ksproc klib
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
