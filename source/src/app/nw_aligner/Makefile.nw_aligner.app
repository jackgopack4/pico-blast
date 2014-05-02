# $Id: Makefile.nw_aligner.app 208174 2010-10-14 16:52:22Z serovav $
# Author:  Yuri Kapustin

# Generic pairwise global alignment utility

WATCHERS = kapustin

APP = nw_aligner
SRC = nwa

LIB = xalgoalignnw tables $(SOBJMGR_LIBS)

LIBS = $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

REQUIRES = objects algo
