#################################
# $Id: Makefile.ncfetch.app 193462 2010-06-03 20:16:09Z kazimird $
#################################

APP = ncfetch.cgi
SRC = ncfetch

LIB = xcgi xconnserv xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = kazimird
