#################################
# $Id: Makefile.formatguess.app 371965 2012-08-14 12:45:11Z ludwigf $
# Author:  Frank Ludwig
#################################

# Build application "formatguess"
#################################

APP = formatguess
SRC = formatguess
LIB = $(OBJREAD_LIBS) seqset $(SEQ_LIBS) pub medline biblio general \
      xser xutil xncbi

REQUIRES = objects -Cygwin


WATCHERS = ludwigf
