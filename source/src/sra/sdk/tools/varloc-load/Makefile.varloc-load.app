# $Id: Makefile.varloc-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = varloc-load
SRC = varloc-load

LIB = align-reader$(DLL) $(UPDATE_SCHEMA_LIBS) load wvdb wkdb ksrch$(DLL) \
      kapp kq vfs kurl srapath krypto kproc kfg kfs rdbms klib judy \
      $(FTDS_LIB) $(BZ2_LIB) $(Z_LIB)
LIBS = $(FTDS_LIBS) $(SRA_SDK_SYSLIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

REQUIRES = FreeTDS
