# $Id: Makefile.netschedule_node_sample.app 191176 2010-05-10 16:12:20Z vakatov $

APP = netschedule_node_sample
SRC = netschedule_node_sample

### BEGIN COPIED SETTINGS

LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

### END COPIED SETTINGS


WATCHERS = kazimird
