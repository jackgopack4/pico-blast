#################################
# $Id: Makefile.biosample_chk.app 398297 2013-05-03 21:10:05Z rafanovi $
# Author:  Colleen Bollin, based on file by Mati Shomrat
#################################

# Build application "biosample_chk"
#################################

APP = biosample_chk
SRC = biosample_chk util src_table_column
LIB = xvalidate xcleanup $(XFORMAT_LIBS) xalnmgr xobjutil \
      valid valerr submit taxon3 gbseq \
      tables xregexp $(PCRE_LIB) $(OBJMGR_LIBS)

LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin


WATCHERS = bollin
