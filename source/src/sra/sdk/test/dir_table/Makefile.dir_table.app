# $Id: Makefile.dir_table.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = dir_table
SRC = dir_table
LIB = srapath$(FORCE_STATIC) wsraschema$(FORCE_STATIC) $(UPDATE_SCHEMA_LIBS) \
      wvdb wkdb kapp vfs kurl srapath krypto kfg kfs ksrch kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
