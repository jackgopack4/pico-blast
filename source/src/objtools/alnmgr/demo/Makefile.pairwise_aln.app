# $Id: Makefile.pairwise_aln.app 208173 2010-10-14 16:51:01Z serovav $

APP = pairwise_aln
SRC = pairwise_aln_app
LIB = submit $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

WATCHERS = todorov
