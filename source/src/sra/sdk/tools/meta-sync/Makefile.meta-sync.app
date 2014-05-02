# $Id: Makefile.meta-sync.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = meta-sync
SRC = meta-sync

LIB = srapath$(FORCE_STATIC) sraschema vxf$(DLL) vdb kdb kxml kapp \
      vfs kfg kurl krypto kfs rdbms kproc klib $(FTDS_LIB) $(Z_LIB) $(BZ2_LIB)
LIBS = $(FTDS_LIBS) $(LIBXML_STATIC_LIBS) $(SRA_SDK_SYSLIBS) $(NETWORK_LIBS) \
       $(ORIG_LIBS)

REQUIRES = FreeTDS LIBXML

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
