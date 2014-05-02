# $Id: Makefile.test_ncbi_service.app 352004 2012-02-02 16:55:18Z lavr $

APP = test_ncbi_service
SRC = test_ncbi_service
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

WATCHERS = lavr
