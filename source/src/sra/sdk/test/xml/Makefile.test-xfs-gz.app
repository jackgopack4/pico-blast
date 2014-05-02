# $Id: Makefile.test-xfs-gz.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = test-xfs-gz
SRC = test-xfs-gz

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kxfs kxml kapp vfs srapath krypto kfg kfs ksproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(DL_LIBS) $(LIBXML_LIBS) $(Z_LIBS) $(BZ2_LIBS) $(ORIG_LIBS)

# CHECK_CMD = 
# CHECK_COPY = test-xfs
