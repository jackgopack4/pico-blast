# $Id: Makefile.localfinder.app 398619 2013-05-07 16:15:55Z rafanovi $
#
# Makefile for 'localfinder' app

SRC = local_finder
APP = localfinder

LIB  = xalgognomon xalgoseq xalnmgr $(OBJREAD_LIBS) xobjutil taxon1 creaders \
       tables xregexp $(PCRE_LIB) xconnect $(SOBJMGR_LIBS)
LIBS = $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

# These are necessary to avoid build errors in some configurations
# (notably 32-bit SPARC WorkShop Release).
CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

WATCHERS = chetvern
