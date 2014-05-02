#################################
# $Id: Makefile.speedtest.app 386642 2013-01-22 16:42:57Z ucko $
# Author:  Frank Ludwig
#################################

# Build application "speedtest"
#################################

APP = speedtest
SRC = speedtest
LIB = prosplign xalgoalignutil xcleanup submit $(BLAST_LIBS) \
      xqueryparse xregexp $(PCRE_LIB) $(OBJMGR_LIBS:%=%$(STATIC))

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

REQUIRES = objects algo -Cygwin


WATCHERS = ludwigf
