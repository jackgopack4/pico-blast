# $Id: Makefile.gi2taxid.app 191176 2010-05-10 16:12:20Z vakatov $
# Makefile for 'gi2taxid' demo app
#

APP = gi2taxid
SRC = gi2taxid

LIB = id1cli id1 taxon1 seqset $(SEQ_LIBS) pub medline biblio general xser xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects

WATCHERS = dicuccio
