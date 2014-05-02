# $Id: Makefile.writedb_unit_test.app 398621 2013-05-07 16:16:12Z rafanovi $

APP = writedb_unit_test
SRC = writedb_unit_test

CPPFLAGS = -DNCBI_MODULE=BLASTDB $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)
CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(FAST_LDFLAGS)

LIB_ = test_boost writedb seqdb $(OBJREAD_LIBS) xobjutil blastdb \
       $(SOBJMGR_LIBS)
LIB = $(LIB_:%=%$(STATIC))
LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_REQUIRES = in-house-resources
CHECK_CMD = writedb_unit_test
CHECK_COPY = writedb_unit_test.ini data

WATCHERS = maning madden camacho
