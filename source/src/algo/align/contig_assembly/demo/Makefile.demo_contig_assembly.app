# $Id: Makefile.demo_contig_assembly.app 208175 2010-10-14 16:52:45Z serovav $

WATCHERS = jcherry

ASN_DEP = seq

APP = demo_contig_assembly
SRC = demo_contig_assembly
LIB = xalgocontig_assembly xalgoalignnw xalgoseq xregexp $(PCRE_LIB) xalnmgr \
      taxon1 $(BLAST_LIBS) $(OBJMGR_LIBS) 


CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(FAST_LDFLAGS)
LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects

