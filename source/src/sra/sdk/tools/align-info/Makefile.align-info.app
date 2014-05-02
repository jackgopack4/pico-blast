# $Id: Makefile.align-info.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = align-info
SRC = align-info

LIB = kapp sraschema align-reader$(DLL) axf$(DLL) sraxf$(DLL) vxf$(DLL) \
      ksrch$(DLL) vdb kdb vfs kurl srapath krypto kfg kfs kproc klib judy \
      $(BZ2_LIB) $(Z_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
