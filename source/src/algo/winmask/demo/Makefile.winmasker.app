# $Id: Makefile.winmasker.app 398619 2013-05-07 16:15:55Z rafanovi $

WATCHERS = dicuccio

ASN_DEP = seq

APP = winmasker
SRC = main win_mask_app
LIB = xalgowinmask \
	  xblast xnetblastcli xnetblast scoremat seqdb blastdb tables \
	  $(OBJREAD_LIBS) xobjutil $(OBJMGR_LIBS)
LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

