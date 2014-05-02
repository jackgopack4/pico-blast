# $Id: Makefile.latf-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = latf-load
SRC = fastq-loader loader-imp

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB_ = fastqloader loader align-writer kapp load wvdb wkdb vfs srapath kurl \
       kfg krypto kfs kq kproc klib judy
# leave off kq on Windows per upstream Makefile?
LIB = $(UPDATE_SCHEMA_LIBS) ksrch $(LIB_:%=%$(FORCE_STATIC)) \
      $(BZ2_LIB) $(Z_LIB)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
