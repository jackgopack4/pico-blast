# $Id: Makefile.unit_test_basic_cleanup.app 374920 2012-09-14 14:16:47Z kornbluh $

APP = unit_test_basic_cleanup
SRC = unit_test_basic_cleanup

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = test_boost xcleanup xregexp $(XFORMAT_LIBS) xalnmgr xobjutil submit tables gbseq $(OBJMGR_LIBS) $(PCRE_LIB)
LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =
CHECK_COPY = test_cases
CHECK_TIMEOUT = 1200

WATCHERS = bollin kornbluh
