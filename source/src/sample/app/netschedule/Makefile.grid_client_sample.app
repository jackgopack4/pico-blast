# $Id: Makefile.grid_client_sample.app 196780 2010-07-08 16:50:11Z kazimird $

APP = grid_client_sample
SRC = grid_client_sample

### BEGIN COPIED SETTINGS

LIB = xconnserv xthrserv xconnect xutil xncbi 

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

### END COPIED SETTINGS

WATCHERS = kazimird
