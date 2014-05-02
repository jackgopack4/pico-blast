# $Id: Makefile.sam-dump.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sam-dump
SRC = sam-dump

LIB = kapp align-reader $(READONLY_SCHEMA_LIBS) sraschema vdb kdb \
      vfs kurl srapath$(FORCE_STATIC) krypto kfg kfs ksrch kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
