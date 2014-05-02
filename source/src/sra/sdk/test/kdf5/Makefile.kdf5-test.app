# $Id: Makefile.kdf5-test.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kdf5-test
SRC = kdf5-test

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath krypto kdf5 kfg kfs ksproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(HDF5_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = HDF5
# unix

# CHECK_CMD = 1.sh /CHECK_NAME=kdf5_test
# CHECK_COPY = 1.sh testfile.h5
