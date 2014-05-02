# $Id: Makefile.test-sra.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-sra
SRC = test-sra
LIB = align-reader$(DLL) $(READONLY_SCHEMA_LIBS) ksrch$(DLL) sradb sraschema \
      vdb kdb kapp vfs srapath kurl krypto kfg kfs kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

# XXX - needs arguments
# CHECK_CMD =
