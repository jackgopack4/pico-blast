# $Id: Makefile.nmer_repeats.app 371965 2012-08-14 12:45:11Z ludwigf $
# Author:  Josh Cherry

# Build n-mer nucleotide repeat finder app

APP = nmer_repeats
SRC = nmer_repeats
LIB = xalgoseq xalnmgr $(OBJREAD_LIBS) xobjutil \
      taxon1 xconnect tables xregexp $(PCRE_LIB) $(SOBJMGR_LIBS)
LIBS = $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

REQUIRES = objects algo

WATCHERS = ludwigf
