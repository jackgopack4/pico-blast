# $Id: Makefile.test_nsstorage.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = test_nsstorage
SRC = test_nsstorage
LIB = xconnserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = kazimird
