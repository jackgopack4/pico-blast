# $Id: Makefile.qual-recal.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = qual-recal
SRC = qual-recal

LIB = kapp wvdb wkdb $(UPDATE_SCHEMA_LIBS) ksrch kproc vfs krypto \
      kfg kfs klib $(BZ2_LIB) $(Z_LIB)
LIBS = $(BZ2_LIBS) $(Z_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
