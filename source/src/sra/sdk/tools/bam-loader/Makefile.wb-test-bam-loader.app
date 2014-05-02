# $Id: Makefile.wb-test-bam-loader.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = wb-test-bam-loader
SRC = bam-reader wb-test-bam-loader

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = ktst loader load kapp ncbi-bam align-writer wvdb wkdb \
      $(UPDATE_SCHEMA_LIBS) ksrch vfs kurl srapath krypto kfg kfs$(DLL) kq \
      kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =
