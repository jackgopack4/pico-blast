# $Id: Makefile.seqdb_perf.app 340120 2011-10-05 16:10:29Z camacho $

APP = seqdb_perf
SRC = seqdb_perf
LIB_ = seqdb xobjutil blastdb $(SOBJMGR_LIBS)
LIB = $(LIB_:%=%$(STATIC))

CFLAGS    = $(FAST_CFLAGS)
CXXFLAGS  = $(FAST_CXXFLAGS)
LDFLAGS   = $(FAST_LDFLAGS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = maning madden camacho
