# $Id: Makefile.unit_test_seq_loc_util.app 310940 2011-07-07 14:39:44Z grichenk $

APP = unit_test_seq_loc_util
SRC = unit_test_seq_loc_util

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = test_boost xobjutil $(SOBJMGR_LIBS)
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =

WATCHERS = vasilche grichenk
