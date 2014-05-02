# $Id: Makefile.test-ram-file-c.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-ram-file-c
SRC = test-ramfile

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kfg krypto kfs kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# Fails as of 2.3.1 because offsetted writes can wind up mid-buffer.
# CHECK_CMD =
