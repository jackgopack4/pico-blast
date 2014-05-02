# $Id: Makefile.fd-leak.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = fd-leak
SRC = fd-leak

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp ksrch sradb sraschema vdb kdb vfs kurl srapath kfg krypto \
      kfs kproc ktst klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = unix

CHECK_CMD =
CHECK_REQUIRES = DLL
