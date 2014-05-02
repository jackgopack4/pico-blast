# $Id: Makefile.netcache_client_sample.app 398247 2013-05-03 18:57:52Z rafanovi $

APP = netcache_client_sample
SRC = netcache_client_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS

LIB = xconnserv xthrserv xconnect xcompress $(CMPRS_LIB) xutil xncbi
LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

### END COPIED SETTINGS

WATCHERS = kazimird
WATCHERS = vakatov
