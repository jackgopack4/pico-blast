# $Id: Makefile.vdb-lock.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-lock
SRC = vdb-lock
LIB = kapp$(FORCE_STATIC) wvdb wkdb vfs kurl srapath$(FORCE_STATIC) krypto \
      kfg kfs kproc$(FORCE_STATIC) klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
