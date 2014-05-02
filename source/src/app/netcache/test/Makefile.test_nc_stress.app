# $Id: Makefile.test_nc_stress.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = test_nc_stress
SRC = test_nc_stress
LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = gouriano
