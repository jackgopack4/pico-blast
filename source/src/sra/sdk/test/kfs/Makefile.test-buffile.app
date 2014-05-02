# $Id: Makefile.test-buffile.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

# Renamed to allow test-buffile as a (temporary) directory name.
APP = test_buffile
SRC = test-buffile

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kfg krypto kfs kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD =
CHECK_TIMEOUT = 400
