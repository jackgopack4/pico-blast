# $Id: Makefile.test_ncbi_namedpipe.app 171524 2009-09-24 18:21:25Z lavr $

APP = test_ncbi_namedpipe
SRC = test_ncbi_namedpipe
LIB = xconnect xncbi

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_REQUIRES = -Cygwin

CHECK_CMD = test_ncbi_namedpipe.sh
CHECK_COPY = test_ncbi_namedpipe.sh

WATCHERS = ivanov lavr
