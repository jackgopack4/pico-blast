# $Id: Makefile.sam-dump.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sam-dump3
SRC = inputfiles sam-dump-opts out_redir sam-hdr matecache read_fkt \
      sam-aligned sam-unaligned cg_tools sam-dump sam-dump3
LIB = kapp align-reader $(READONLY_SCHEMA_LIBS) sraschema vdb kdb \
      vfs kurl srapath$(FORCE_STATIC) krypto kfg kfs ksrch kproc klib judy \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) -DNCBI $(ORIG_CPPFLAGS)
