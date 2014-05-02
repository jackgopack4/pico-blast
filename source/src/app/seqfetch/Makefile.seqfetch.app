#################################
# $Id: Makefile.seqfetch.app 398620 2013-05-07 16:16:00Z rafanovi $
# Author:  Mati Shomrat
#################################

# Build application "seqfetch"
#################################

APP = seqfetch
SRC = seqfetch
LIB = xobjwrite $(OBJREAD_LIBS) xobjutil gbseq xalnmgr entrez2cli entrez2 tables $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin


WATCHERS = ludwigf
