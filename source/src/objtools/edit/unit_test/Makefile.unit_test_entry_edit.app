# $Id: Makefile.unit_test_entry_edit.app 391148 2013-03-05 20:17:15Z kornbluh $

APP = unit_test_entry_edit
SRC = unit_test_entry_edit

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB  = xobjedit xvalidate $(XFORMAT_LIBS) xalnmgr xobjutil valid valerr \
       taxon3 gbseq submit tables xregexp $(PCRE_LIB) test_boost $(OBJMGR_LIBS) 
LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =
CHECK_COPY = test_cases
CHECK_TIMEOUT = 3000

WATCHERS = bollin kornbluh
