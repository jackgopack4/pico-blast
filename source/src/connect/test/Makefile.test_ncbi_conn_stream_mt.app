# $Id: Makefile.test_ncbi_conn_stream_mt.app 350431 2012-01-20 15:01:04Z lavr $

APP = test_ncbi_conn_stream_mt
SRC = test_ncbi_conn_stream_mt
LIB = connssl xconnect test_mt xncbi

LIBS = $(GNUTLS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

CHECK_CMD = test_ncbi_conn_stream_mt.sh
CHECK_COPY = test_ncbi_conn_stream_mt.sh ../../check/ncbi_test_data

WATCHERS = lavr
