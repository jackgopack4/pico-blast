#################################
# $Id: Makefile.lds2_sample.app 398629 2013-05-07 16:16:59Z rafanovi $
#################################

REQUIRES = objects SQLITE3

APP = lds2_sample
SRC = lds2_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB  = ncbi_xloader_lds2 lds2 $(OBJREAD_LIBS) xobjutil sqlitewrapp creaders xcompress $(COMPRESS_LIBS) $(SOBJMGR_LIBS)

LIBS = $(SQLITE3_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = grichenk
