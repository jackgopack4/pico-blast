# $Id: Makefile.test-resolver.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-resolver
SRC = resolvertest

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vdb kdb vfs srapath kurl kfg krypto kfs kproc ktst klib judy \
      $(Z_LIB) $(BZ2_LIB)
# ksrch?
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
CHECK_COPY = ncbi resolver.kfg
CHECK_REQUIRES = CURL
