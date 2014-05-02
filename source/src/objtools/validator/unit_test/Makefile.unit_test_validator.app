# $Id: Makefile.unit_test_validator.app 374920 2012-09-14 14:16:47Z kornbluh $

APP = unit_test_validator
SRC = unit_test_validator wrong_qual

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB  = xvalidate $(XFORMAT_LIBS) xalnmgr xobjutil valid valerr taxon3 gbseq submit \
       tables xregexp $(PCRE_LIB) test_boost $(OBJMGR_LIBS) 
LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =
CHECK_COPY = unit_test_validator.ini
CHECK_TIMEOUT = 3000

WATCHERS = bollin kans kornbluh
