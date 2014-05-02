# $Id: Makefile.id1_fetch.app 374920 2012-09-14 14:16:47Z kornbluh $

APP = id1_fetch
SRC = id1_fetch
LIB = $(XFORMAT_LIBS) xalnmgr gbseq xobjutil id1cli submit entrez2cli entrez2 tables \
      $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin

WATCHERS = ucko
