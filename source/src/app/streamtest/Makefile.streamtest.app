#################################
# $Id: Makefile.streamtest.app 386642 2013-01-22 16:42:57Z ucko $
# Author:  Frank Ludwig
#################################

# Build application "streamtest"
#################################

APP = streamtest
SRC = streamtest
LIB = prosplign xalgoalignutil xalgoseq xmlwrapp \
      xvalidate xcleanup xobjwrite $(XFORMAT_LIBS) \
      valid valerr taxon1 taxon3 $(BLAST_LIBS) \
      xqueryparse xregexp $(PCRE_LIB) $(OBJMGR_LIBS)

LIBS = $(LIBXSLT_LIBS) $(LIBXML_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) \
      $(PCRE_LIBS) $(ORIG_LIBS)

REQUIRES = objects algo LIBXSLT

WATCHERS = kans
