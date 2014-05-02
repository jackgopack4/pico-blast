# $Id: Makefile.sra-pileup.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sra-pileup
SRC = cmdline_cmn reref sra-pileup
LIB = kapp align-reader $(READONLY_SCHEMA_LIBS) sraschema vdb kdb \
      vfs kurl srapath$(FORCE_STATIC) krypto kfg kfs ksrch kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -DNCBI $(ORIG_CPPFLAGS)

# CHECK_CMD = 1.sh /CHECK_NAME=sra_pileup
# CHECK_COPY = 1.sh
# CHECK_REQUIRES = unix LFS
# CHECK_TIMEOUT = 400
