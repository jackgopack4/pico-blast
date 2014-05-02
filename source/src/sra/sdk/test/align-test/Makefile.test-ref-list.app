# $Id: Makefile.test-ref-list.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-ref-list
SRC = test-ref-list

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp align-reader $(READONLY_SCHEMA_LIBS) sraschema vdb kdb vfs kurl \
      srapath$(FORCE_STATIC) krypto kproc kfg kfs ksrch ktst klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD =

# REQUIRES = unix
