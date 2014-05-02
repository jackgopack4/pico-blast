#################################
# $Id: Makefile.netcache_control.app 191176 2010-05-10 16:12:20Z vakatov $
#################################

APP = netcache_control
SRC = netcache_control

LIB = ncbi_xcache_netcache xconnserv xthrserv xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = kazimird
