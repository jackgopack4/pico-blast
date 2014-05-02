# $Id: Makefile.unit_test_autodef.app 387374 2013-01-29 15:10:33Z ucko $

APP = unit_test_autodef
SRC = unit_test_autodef

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB  = xobjedit xvalidate $(XFORMAT_LIBS) xalnmgr xobjutil valid valerr \
       taxon3 gbseq submit tables xregexp $(PCRE_LIB) test_boost $(OBJMGR_LIBS) 
LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =
CHECK_COPY = 
CHECK_TIMEOUT = 3000

WATCHERS = bollin
