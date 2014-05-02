# $Id: Makefile.vdb-copy.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-copy
SRC = num-gen context helper coldefs get_platform namelist_tools progressbar \
      copy_meta type_matcher redactval config_values vdb-copy
LIB = wsraschema$(FORCE_STATIC) $(UPDATE_SCHEMA_LIBS) align-reader wvdb \
      wsradb wkdb kapp vfs kurl srapath$(FORCE_STATIC) krypto kfg kfs ksrch \
      kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
