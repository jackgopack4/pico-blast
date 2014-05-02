# $Id: Makefile.test_netschedule_crash.app 364356 2012-05-24 15:36:47Z satskyse $

APP = test_netschedule_crash
SRC = test_netschedule_crash
LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
REQUIRES = Linux

WATCHERS = satskyse
