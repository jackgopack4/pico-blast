# $Id: Makefile.test-reference-mgr.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-reference-mgr
SRC = test-reference-mgr

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp align-writer $(UPDATE_SCHEMA_LIBS) sraschema wvdb wkdb vfs kurl \
      srapath$(FORCE_STATIC) krypto kproc kfg kfs ksrch ktst klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD = test-reference-mgr.sh
# CHECK_COPY = test-reference-mgr.sh
# CHECK_REQUIRES = DLL

# REQUIRES = unix
