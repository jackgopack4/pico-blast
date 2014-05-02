# $Id: Makefile.refseq-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = refseq-load
SRC = context refseq-load

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = sraschema$(FORCE_STATIC) wsraxf$(DLL) wvxf$(DLL) waxf$(DLL) \
      align-writer load wvdb wkdb kapp vfs kurl srapath$(FORCE_STATIC) \
      krypto kfg kfs ksrch kq kproc klib judy $(Z_LIB) $(BZ2_LIB)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = CURL
# unix
