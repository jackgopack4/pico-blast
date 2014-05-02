# $Id: Makefile.run-stat.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = run-stat
SRC = num-gen context helper progressbar mod_cmn key_value rd_filter \
      mod_reads_helper mod_reads svg chart run-stat

LIB = sraschema$(FORCE_STATIC) align-reader$(DLL) $(READONLY_SCHEMA_LIBS) \
      vdb kdb kapp vfs kurl srapath$(FORCE_STATIC) krypto kfg kfs ksrch \
      kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
