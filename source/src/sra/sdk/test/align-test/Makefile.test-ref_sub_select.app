# $Id: Makefile.test-ref_sub_select.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-ref_sub_select
SRC = test-ref_sub_select

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = align-writer $(UPDATE_SCHEMA_LIBS) sraschema wvdb wkdb kapp vfs kurl \
      srapath$(FORCE_STATIC) krypto kproc kfg kfs ksrch ktst klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = test-ref_sub_select.sh
CHECK_COPY = test-ref_sub_select.sh
CHECK_REQUIRES = DLL -MSWin

# REQUIRES = unix
