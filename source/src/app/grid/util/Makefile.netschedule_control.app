#################################
# $Id: Makefile.netschedule_control.app 191176 2010-05-10 16:12:20Z vakatov $
#################################

APP = netschedule_control
SRC = netschedule_control

LIB = xconnserv xthrserv xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = kazimird
