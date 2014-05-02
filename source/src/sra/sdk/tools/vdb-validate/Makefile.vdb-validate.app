# $Id: Makefile.vdb-validate.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-validate
SRC = vdb-validate
LIB = align-reader$(DLL) $(READONLY_SCHEMA_LIBS) ksrch sradb sraschema \
      vdb kdb kapp vfs kurl srapath krypto kfg kfs kproc klib judy \
      $(BZ2_LIB) $(Z_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
