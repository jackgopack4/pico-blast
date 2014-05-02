#################################
# $Id: Makefile.asn_cleanup.app 374920 2012-09-14 14:16:47Z kornbluh $
# Author:  Colleen Bollin, based on file by Mati Shomrat
#################################

# Build application "asn_cleanup"
#################################

APP = asn_cleanup
SRC = asn_cleanup
LIB = $(XFORMAT_LIBS) xobjutil xalnmgr xcleanup xregexp entrez2cli \
    entrez2 tables $(OBJMGR_LIBS) $(PCRE_LIB)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin


WATCHERS = bollin
