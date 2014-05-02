#################################
# $Id: Makefile.lds2_indexer.app 371965 2012-08-14 12:45:11Z ludwigf $
#################################

REQUIRES = objects SQLITE3

APP = lds2_indexer
SRC = lds2_indexer

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = lds2 $(OBJREAD_LIBS) xobjutil sqlitewrapp xcompress $(COMPRESS_LIBS) $(SOBJMGR_LIBS) submit
LIBS = $(SQLITE3_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(ORIG_LIBS)

### END COPIED SETTINGS

WATCHERS = grichenk
