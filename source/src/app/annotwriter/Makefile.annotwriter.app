#################################
# $Id: Makefile.annotwriter.app 371965 2012-08-14 12:45:11Z ludwigf $
# Author:  Mati Shomrat
#################################

# Build application "annotwriter"
#################################

APP = annotwriter
SRC = annotwriter
LIB = xobjwrite ${OBJREAD_LIBS} xobjutil gbseq xalnmgr entrez2cli entrez2 \
	tables $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin


WATCHERS = ludwigf
