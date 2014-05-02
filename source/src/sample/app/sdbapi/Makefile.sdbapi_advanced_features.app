# $Id: Makefile.sdbapi_advanced_features.app 370257 2012-07-27 14:56:37Z ivanovp $

REQUIRES = dbapi

APP = sdbapi_advanced_features
SRC = sdbapi_advanced_features

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB  = $(SDBAPI_LIB) xconnect xutil xncbi
LIBS = $(SDBAPI_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = ucko mcelhany
