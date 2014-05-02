# $Id: Makefile.test_netschedule_stress.app 358738 2012-04-05 00:17:07Z kazimird $

APP = test_netschedule_stress
SRC = test_netschedule_stress
LIB = xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = satskyse
