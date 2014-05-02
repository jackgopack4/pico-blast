# $Id: Makefile.test-cipher-speed.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-cipher-speed
SRC = test-cipher-speed

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kfg kryptotest kproc kfs klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CHECK_CMD = test-cipher-speed -t 1
REQUIRES = Linux GCC
