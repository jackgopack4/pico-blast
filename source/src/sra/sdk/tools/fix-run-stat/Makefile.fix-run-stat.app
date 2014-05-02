# $Id: Makefile.fix-run-stat.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = fix-run-stat
SRC = fix-run-stat

LIB = kapp align-reader$(DLL) wsradb srapath$(FORCE_STATIC) \
      sraschema$(FORCE_STATIC) $(READONLY_SCHEMA_LIBS) wvdb wkdb \
      kxml kfg kfs ksrch$(DLL) vfs krypto kproc klib $(BZ2_LIB) $(Z_LIB)
LIBS = $(LIBXML_LIBS) $(BZ2_LIBS) $(Z_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

REQUIRES = LIBXML
