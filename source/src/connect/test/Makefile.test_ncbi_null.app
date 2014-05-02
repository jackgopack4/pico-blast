# $Id: Makefile.test_ncbi_null.app 389945 2013-02-21 22:03:51Z lavr $

APP = test_ncbi_null
SRC = test_ncbi_null
LIB = xconnect xncbi

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

WATCHERS = lavr
