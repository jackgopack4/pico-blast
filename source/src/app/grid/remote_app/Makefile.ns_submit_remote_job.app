# $Id: Makefile.ns_submit_remote_job.app 196780 2010-07-08 16:50:11Z kazimird $

APP = ns_submit_remote_job
SRC = ns_submit_remote_job
LIB = xconnserv xthrserv xconnect xutil xncbi 

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = kazimird
