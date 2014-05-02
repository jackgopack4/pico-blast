# $Id: Makefile.test-csprng.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-csprng
SRC = test-csprng

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = krypto kapp kfs klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

CHECK_CMD  =
