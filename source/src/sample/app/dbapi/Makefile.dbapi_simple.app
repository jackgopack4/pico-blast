# $Id: Makefile.dbapi_simple.app 373656 2012-08-31 15:16:14Z mcelhany $

REQUIRES = dbapi FreeTDS

APP = dbapi_simple
SRC = dbapi_simple

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = ncbi_xdbapi_ftds $(FTDS_LIB) \
      dbapi_util_blobstore$(STATIC) dbapi$(STATIC) dbapi_driver$(STATIC) \
      $(XCONNEXT) xconnect $(COMPRESS_LIBS) xutil xncbi
LIBS = $(FTDS_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

# CHECK_CMD =
# CHECK_COPY =

WATCHERS = ucko mcelhany
