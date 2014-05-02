# $Id: Makefile.test_gridclient_stress.app 196780 2010-07-08 16:50:11Z kazimird $

APP = test_gridclient_stress
SRC = test_gridclient_stress
LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_COPY = test_gridclient_stress.ini

WATCHERS = kazimird
