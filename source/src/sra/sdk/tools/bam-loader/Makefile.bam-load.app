# $Id: Makefile.bam-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = bam-load
SRC = bam-loader alignment-writer reference-writer sequence-writer loader-imp

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = load kapp ncbi-bam align-writer wvdb wkdb waxf$(DLL) wsraxf$(DLL) \
      wvxf$(DLL) ksrch vfs kurl srapath krypto kfg kfs kq kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
