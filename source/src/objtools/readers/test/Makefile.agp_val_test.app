#################################
# $Id: Makefile.agp_val_test.app 386637 2013-01-22 16:35:54Z ucko $
#################################

REQUIRES = objects

APP = agp_val_test
SRC = agp_val_test

LIB = $(OBJREAD_LIBS) seqset $(SEQ_LIBS) pub medline biblio general \
      xser xutil xncbi

WATCHERS = sapojnik
