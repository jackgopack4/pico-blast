# $Id: Makefile.ncbi_applog.app 355496 2012-03-06 17:45:10Z ivanov $

APP = ncbi_applog
SRC = ncbi_applog
LIB = xconnect xncbi clog

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)

WATCHERS = ivanov
