# $Id: Makefile.prefetch.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = prefetch
SRC = prefetch
LIB = sraschema$(FORCE_STATIC) sraxf$(DLL) vxf$(DLL) vdb kapp kdb vfs kurl \
      srapath$(FORCE_STATIC) krypto kfg kfs ksrch kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
