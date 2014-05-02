# $Id: Makefile.test-fastq-loader.app 14850 2013-03-18 19:25:30Z ucko $

WATCHERS = ucko

APP = test-fastq-loader
SRC = test-fastq-loader

LIB_ = fastqloader loader align-writer kapp ktst load wvdb wkdb \
       vfs kurl srapath kfg krypto kq kproc kfs klib judy
LIB = $(UPDATE_SCHEMA_LIBS) ksrch $(LIB_:%=%$(FORCE_STATIC)) \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -I../../../tools/loader \
           -I$(includedir)/../src/internal/sra/sdk/tools/loader \
           -I$(includedir)/../src/sra/sdk/tools/loader $(ORIG_CPPFLAGS)

CHECK_CMD =
CHECK_REQUIRES = DLL -MSWin
