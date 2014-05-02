# $Id: Makefile.csra-trim.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = csra-trim
SRC = deseq

LIB = kapp align-reader wvdb wkdb $(UPDATE_SCHEMA_LIBS) ksrch vfs kurl \
      srapath krypto kproc kfg kfs klib judy $(BZ2_LIB) $(Z_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
