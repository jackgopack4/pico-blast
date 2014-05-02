#################################
# $Id: Makefile.soap_server_sample.app 191176 2010-05-10 16:12:20Z vakatov $
#################################

APP = soap_server_sample
SRC = soap_server_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = soap_dataobj xsoap_server xsoap xcgi xconnect xser xutil xncbi
LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = gouriano
