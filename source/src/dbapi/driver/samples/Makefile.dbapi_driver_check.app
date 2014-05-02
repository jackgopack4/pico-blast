# $Id: Makefile.dbapi_driver_check.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = dbapi_driver_check
SRC = dbapi_driver_check

LIB  = dbapi_driver xncbi
LIBS = $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = ucko
