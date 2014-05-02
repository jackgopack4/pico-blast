#################################
# $Id: Makefile.asn2flat.app 398626 2013-05-07 16:16:43Z rafanovi $
# Author:  Mati Shomrat
#################################

# Build application "asn2flat"
#################################

APP = asn2flat
SRC = asn2flat

LIB  = xcleanup $(OBJREAD_LIBS) $(XFORMAT_LIBS) xalnmgr xobjutil entrez2cli entrez2 tables xregexp $(PCRE_LIB) $(OBJMGR_LIBS)
LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin

WATCHERS = ludwigf
