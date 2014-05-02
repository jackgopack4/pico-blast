# $Id: Makefile.cg-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = cg-load
SRC = file-version-factory file f1_3 f1_5 f2_0 f2_2 factory-reads \
      factory-mappings factory-evidence-intervals factory-evidence-dnbs \
      writer-seq writer-algn writer-evidence-intervals writer-evidence-dnbs \
      cg-load

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = load kapp align-writer waxf$(DLL) wsraxf$(DLL) wvxf$(DLL) wvdb wkdb vfs \
      kurl srapath krypto ksrch kfg kfs kq kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# REQUIRES = unix
