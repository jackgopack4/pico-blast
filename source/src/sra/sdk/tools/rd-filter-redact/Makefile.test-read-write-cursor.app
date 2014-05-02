# $Id: Makefile.test-read-write-cursor.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-read-write-cursor
SRC = test-read-write-cursor
LIB = srapath$(FORCE_STATIC) sraschema$(FORCE_STATIC) $(UPDATE_SCHEMA_LIBS) \
      wvdb wsradb wkdb kapp vfs kurl srapath krypto kfg kfs ksrch kproc klib \
      judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

# CHECK_CMD =
# CHECK_REQUIRES = Linux
