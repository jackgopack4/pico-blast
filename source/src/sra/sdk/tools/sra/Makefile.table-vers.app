# $Id: Makefile.table-vers.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = table-vers
SRC = table-vers
LIB = vxf$(DLL) vdb kdb vfs kurl srapath kapp krypto kfg kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
