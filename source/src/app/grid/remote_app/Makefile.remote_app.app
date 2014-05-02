# $Id: Makefile.remote_app.app 380799 2012-11-15 17:36:22Z kazimird $
# Author:  Maxim Didneko
#################################

APP = remote_app
SRC = remote_app_wn exec_helpers

REQUIRES = MT

LIB = xconnserv xthrserv xconnect xutil xncbi 
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = kazimird
