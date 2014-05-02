#################################
# $Id: Makefile.idmapper.app 374920 2012-09-14 14:16:47Z kornbluh $
# Author:  Frank Ludwig
#################################

# Build application "idmapper"
#################################

APP = idmapper
SRC = idmapper
LIB = xobjreadex $(OBJREAD_LIBS) $(XFORMAT_LIBS) xobjutil xalnmgr xcleanup \
	  xregexp entrez2cli entrez2 tables $(OBJMGR_LIBS) $(PCRE_LIB)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin


WATCHERS = ludwigf
