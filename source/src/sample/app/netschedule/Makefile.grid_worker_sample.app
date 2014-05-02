# $Id: Makefile.grid_worker_sample.app 196780 2010-07-08 16:50:11Z kazimird $

APP = grid_worker_sample
SRC = grid_worker_sample

### BEGIN COPIED SETTINGS

LIB = xconnserv xthrserv xconnect xutil xncbi 

REQUIRES = MT

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

### END COPIED SETTINGS

WATCHERS = kazimird
