# $Id: Makefile.test_conn_tar.app 363396 2012-05-16 16:52:47Z lavr $

APP = test_conn_tar
SRC = test_conn_tar
CPPFLAGS = $(CMPRS_INCLUDE) $(ORIG_CPPFLAGS)
LIB = $(COMPRESS_LIBS) connssl xconnect xutil xncbi $(NCBIATOMIC_LIB)

LIBS = $(CMPRS_LIBS) $(GNUTLS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

CHECK_CMD = test_conn_tar.sh
CHECK_COPY = test_conn_tar.sh ../../util/test/test_tar.sh ../../check/ncbi_test_data

WATCHERS = lavr
