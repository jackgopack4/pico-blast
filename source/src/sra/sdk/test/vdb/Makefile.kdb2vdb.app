# $Id: Makefile.kdb2vdb.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kdb2vdb
SRC = kdb2vdb

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp wvdb wkdb vfs kurl srapath kfg krypto kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
