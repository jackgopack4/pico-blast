# $Id: Makefile.sdbapi_simple.app 373538 2012-08-30 13:24:31Z mcelhany $

REQUIRES = dbapi

APP = sdbapi_simple
SRC = sdbapi_simple

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB  = $(SDBAPI_LIB) xconnect xutil xncbi
LIBS = $(SDBAPI_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = ucko mcelhany
