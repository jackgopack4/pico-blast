# $Id: Makefile.vdb-dump.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-dump
SRC = vdb-dump-num-gen vdb-dump-context vdb-dump-coldefs vdb-dump-tools \
      vdb-dump-str vdb-dump-helper vdb-dump-filter vdb-dump-formats vdb-dump

LIB = sraschema$(FORCE_STATIC) align-reader$(DLL) $(READONLY_SCHEMA_LIBS) \
      ksrch vdb kdb vfs srapath kurl krypto kapp kfg kfs kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
