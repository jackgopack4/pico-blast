# $Id: Makefile.test-loader.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-loader
SRC = loadertest

LIB_ = fastqloader loader align-writer kapp ktst load vfs wvdb wkdb kfg \
       krypto kq kproc kfs klib
LIB = $(LIB_:%=%$(FORCE_STATIC)) $(Z_LIB) $(BZ2_LIB)
LIBS = $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -I../../../tools/loader \
           -I$(includedir)/../src/internal/sra/sdk/tools/loader \
           -I$(includedir)/../src/sra/sdk/tools/loader $(ORIG_CPPFLAGS)

CHECK_CMD =
