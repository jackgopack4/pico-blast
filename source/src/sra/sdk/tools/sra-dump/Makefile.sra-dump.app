# $Id: Makefile.sra-dump.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sra-dump
SRC = sra-dump

LIB = kapp sradb sraschema align-reader $(READONLY_SCHEMA_LIBS) vdb kdb \
      vfs srapath kurl krypto kfg kfs ksrch$(DLL) kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
