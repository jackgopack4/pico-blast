# $Id: Makefile.test_ncbi_conn.app 344785 2011-11-18 16:17:45Z lavr $

APP = test_ncbi_conn
SRC = test_ncbi_conn
LIB = xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

CHECK_CMD = test_ncbi_conn.sh
CHECK_COPY = test_ncbi_conn.sh ../../check/ncbi_test_data

WATCHERS = lavr satskyse
