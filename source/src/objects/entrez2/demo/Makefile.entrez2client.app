# ===================================
# $Id: Makefile.entrez2client.app 191176 2010-05-10 16:12:20Z vakatov $
#
# Meta-makefile for entrez2 command-line test app
# Author: Mike DiCuccio
# ===================================

APP = entrez2client
SRC = entrez2client
LIB = entrez2 entrez2cli xconnect xser xutil xncbi
LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects


WATCHERS = dicuccio
