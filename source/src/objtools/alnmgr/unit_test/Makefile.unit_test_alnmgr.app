# $Id: Makefile.unit_test_alnmgr.app 369980 2012-07-25 16:17:55Z grichenk $

APP = unit_test_alnmgr
SRC = unit_test_alnmgr

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = xalnmgr xobjutil submit tables test_boost $(OBJMGR_LIBS)
LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_COPY = data

CHECK_CMD =

WATCHERS = grichenk
