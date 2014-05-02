# $Id: Makefile.demo_seqtest.app 208175 2010-10-14 16:52:45Z serovav $

WATCHERS = jcherry 

ASN_DEP = seq

APP = demo_seqtest
SRC = demo_seqtest
LIB = xalgoseqqa xalgoseq xalgognomon xobjutil seqtest entrez2cli entrez2 \
	xalnmgr tables xregexp taxon1 $(PCRE_LIB) $(OBJMGR_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(FAST_LDFLAGS)
LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = -Cygwin
