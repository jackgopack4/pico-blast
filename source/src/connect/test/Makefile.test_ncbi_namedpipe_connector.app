# $Id: Makefile.test_ncbi_namedpipe_connector.app 375781 2012-09-24 15:07:33Z lavr $

APP = test_ncbi_namedpipe_connector
SRC = test_ncbi_namedpipe_connector ncbi_conntest
LIB = xconnect xncbi

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS) 

CHECK_REQUIRES = -Cygwin

CHECK_CMD = test_ncbi_namedpipe_connector.sh
CHECK_COPY = test_ncbi_namedpipe_connector.sh

WATCHERS = lavr
