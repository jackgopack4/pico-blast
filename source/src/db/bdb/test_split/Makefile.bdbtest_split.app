# $Id: Makefile.bdbtest_split.app 184358 2010-02-26 16:33:57Z ivanov $

APP = bdbtest_split
SRC = test_bdb_split
LIB = $(BDB_CACHE_LIB) $(BDB_LIB) xutil xncbi
LIBS = $(BERKELEYDB_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(ORIG_CPPFLAGS) $(BERKELEYDB_INCLUDE)

WATCHERS = kuznets
