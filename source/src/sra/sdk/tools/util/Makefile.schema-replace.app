# $Id: Makefile.schema-replace.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = schema-replace
SRC = schema-replace
LIB = wsraschema$(FORCE_STATIC) $(UPDATE_SCHEMA_LIBS) align-reader \
      wvdb wkdb vfs kurl srapath$(FORCE_STATIC) krypto kapp kfg kfs ksrch \
      kproc$(FORCE_STATIC) klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
