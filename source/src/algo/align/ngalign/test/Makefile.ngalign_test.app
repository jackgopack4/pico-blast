# $Id: Makefile.ngalign_test.app 398619 2013-05-07 16:15:55Z rafanovi $

ASN_DEP = seq

APP = ngalign_test
SRC = ngalign_test
LIB = xngalign \
      xalgoalignnw xalgoalignutil xalgoseq \
      blastinput $(BLAST_DB_DATA_LOADER_LIBS) $(BLAST_LIBS) \
      align_format gene_info xalnmgr \
      xobjutil $(OBJREAD_LIBS) taxon1  \
      xcgi xhtml xregexp $(PCRE_LIB) xqueryparse \
	  $(GENBANK_LIBS)  $(QOBJMGR_ONLY_LIBS)  \


CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(FAST_LDFLAGS)
LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects

WATCHERS = boukn

