# $Id: Makefile.ns_remote_job_control.app 196780 2010-07-08 16:50:11Z kazimird $

APP = ns_remote_job_control
SRC = ns_remote_job_control info_collector renderer
LIB = xconnserv xthrserv xconnect xutil xncbi 

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = kazimird
