#################################
# $Id: Makefile.agp_count.app 386637 2013-01-22 16:35:54Z ucko $
#################################

APP = agp_count
SRC = agp_count

LIB = $(OBJREAD_LIBS) seqset $(SEQ_LIBS) pub medline biblio general \
      xser xutil xncbi

WATCHERS = sapojnik
