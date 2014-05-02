#################################
# $Id: Makefile.feattree_sample.app 185303 2010-03-10 17:06:00Z mcelhany $
#################################

REQUIRES = objects

APP = feattree_sample
SRC = feattree_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = xobjutil $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = vasilche
