# $Id: Makefile.test_ncbi_heapmgr.app 381019 2012-11-17 20:16:23Z lavr $

APP = test_ncbi_heapmgr
SRC = test_ncbi_heapmgr
LIB = connect

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
# LINK = purify g++

CHECK_CMD =

WATCHERS = lar
