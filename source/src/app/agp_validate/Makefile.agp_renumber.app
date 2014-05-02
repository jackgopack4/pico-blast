#################################
# $Id: Makefile.agp_renumber.app 371965 2012-08-14 12:45:11Z ludwigf $
#################################

REQUIRES = objects

APP = agp_renumber
SRC = agp_renumber

LIB = $(OBJREAD_LIBS) seqset $(SEQ_LIBS) pub medline biblio general \
      xser xutil xncbi

WATCHERS = sapojnik
