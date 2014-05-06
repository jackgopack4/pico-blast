# $Id: Makefile.bdbtest_vmerge.app 309838 2011-06-28 17:01:05Z vakatov $

APP = bdbtest_vmerge
SRC = test_bdb_vmerge
LIB = xalgovmerge $(BDB_CACHE_LIB) $(BDB_LIB) xutil xncbi
LIBS = $(BERKELEYDB_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(ORIG_CPPFLAGS) $(BERKELEYDB_INCLUDE)

WATCHERS = kuznets