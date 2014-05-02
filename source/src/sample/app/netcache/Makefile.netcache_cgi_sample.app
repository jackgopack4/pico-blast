# $Id: Makefile.netcache_cgi_sample.app 359793 2012-04-17 19:03:09Z mcelhany $

APP = netcache_cgi_sample.cgi
SRC = netcache_cgi_sample

### BEGIN COPIED SETTINGS
LIB = xconnserv xconnect xcgi xhtml xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = kazimird
