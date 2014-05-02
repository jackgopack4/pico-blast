# $Id: Makefile.test-vdb-resolve.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-vdb-resolve
SRC = test-vdb-resolve

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = align-reader $(READONLY_SCHEMA_LIBS) ksrch sradb sraschema vdb kdb kapp \
      vfs kurl srapath krypto kfg kfs kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# Need to supply at least one path to resolve
# CHECK_CMD =
