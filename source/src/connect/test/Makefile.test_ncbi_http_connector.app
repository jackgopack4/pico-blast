# $Id: Makefile.test_ncbi_http_connector.app 375781 2012-09-24 15:07:33Z lavr $

APP = test_ncbi_http_connector
SRC = test_ncbi_http_connector ncbi_conntest
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

CHECK_CMD =

WATCHERS = lavr
