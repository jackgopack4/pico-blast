# $Id: Makefile.pacbio-correct-tool.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = pacbio-correct-tool
SRC = pacbio-correct
LIB = kapp wvdb wkdb vfs krypto kfg kfs ksrch kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
