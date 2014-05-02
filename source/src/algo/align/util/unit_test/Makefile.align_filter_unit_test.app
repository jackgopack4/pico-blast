# $Id: Makefile.align_filter_unit_test.app 337391 2011-09-12 15:29:08Z mozese2 $

APP = align_filter_unit_test
SRC = align_filter_unit_test

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = xalgoalignutil xalgoseq xalnmgr xqueryparse tables \
	  taxon1 xregexp $(PCRE_LIB) $(BLAST_LIBS) \
	  test_boost $(OBJMGR_LIBS)

LIBS = $(NETWORK_LIBS) $(PCRE_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included objects

CHECK_CMD = align_filter_unit_test -data-in data/seqalign.asn -filters data/filters
CHECK_COPY = data


WATCHERS = mozese2
