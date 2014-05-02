# $Id: Makefile.test_ncbi_service_connector.app 170864 2009-09-17 16:09:35Z vakatov $

APP = test_ncbi_service_connector
SRC = test_ncbi_service_connector
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

CHECK_CMD =

WATCHERS = lavr
