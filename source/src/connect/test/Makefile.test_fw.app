# $Id: Makefile.test_fw.app 184358 2010-02-26 16:33:57Z ivanov $

APP = test_fw
SRC = test_fw
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)

WATCHERS = lar
