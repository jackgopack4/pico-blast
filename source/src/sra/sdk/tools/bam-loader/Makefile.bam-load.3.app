# $Id: Makefile.bam-load.3.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = bam-load.3
SRC = bam-loader3 bam-reader loader-imp3

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = loader load kapp ncbi-bam align-writer wvdb wkdb $(UPDATE_SCHEMA_LIBS) \
      ksrch vfs kurl srapath krypto kfg kfs kq kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
