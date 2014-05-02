# $Id: Makefile.test_ncbi_download.app 184358 2010-02-26 16:33:57Z ivanov $

APP = test_ncbi_download
SRC = test_ncbi_download
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

WATCHERS = lar
