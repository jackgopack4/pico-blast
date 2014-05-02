# $Id: Makefile.unit-test-blast.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = unit-test-blast
SRC = unit-test-blast

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = ktst kapp srapath$(FORCE_STATIC) align-reader vdb-blast sraschema \
      $(READONLY_SCHEMA_LIBS) vdb kdb vfs kurl srapath krypto kproc kfg \
      kfs ksrch klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
