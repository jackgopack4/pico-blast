#################################
# $Id: Makefile.soap_client_sample.app 178027 2009-12-08 14:48:41Z gouriano $
#################################

APP = soap_client_sample
SRC = soap_client_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = soap_dataobj xsoap xconnect xser xutil xncbi
LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS
#CHECK_CMD = soap_client_sample

WATCHERS = gouriano
