# $Id: Makefile.read-filter-redact.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = read-filter-redact
SRC = read-filter-redact
LIB = sraschema wvxf$(DLL) wvdb wkdb kapp vfs kurl srapath krypto kfg kfs \
      kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
