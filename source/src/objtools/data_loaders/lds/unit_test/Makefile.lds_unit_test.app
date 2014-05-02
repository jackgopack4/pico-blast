# $Id: Makefile.lds_unit_test.app 398623 2013-05-07 16:16:28Z rafanovi $

REQUIRES = Boost.Test.Included bdb objects

APP = lds_unit_test
SRC = lds_unit_test

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = test_boost ncbi_xloader_lds lds $(OBJREAD_LIBS) bdb xobjutil $(OBJMGR_LIBS)
LIBS = $(BERKELEYDB_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_COPY = data
CHECK_CMD = lds_unit_test

WATCHERS = vasilche
