# $Id: Makefile.dustmasker.app 398621 2013-05-07 16:16:12Z rafanovi $

REQUIRES = objects algo

ASN_DEP = seq

APP = dustmasker
SRC = main dust_mask_app

LIB = xalgodustmask seqmasks_io $(OBJREAD_LIBS) xobjutil \
	$(OBJREAD_LIBS) seqdb blastdb $(OBJMGR_LIBS:%=%$(STATIC))

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)


WATCHERS = camacho
