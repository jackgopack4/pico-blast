# $Id: Makefile.test_grid_worker.app 196780 2010-07-08 16:50:11Z kazimird $

APP = test_grid_worker
SRC = test_grid_worker
LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_COPY = test_grid_worker.ini

WATCHERS = kazimird
