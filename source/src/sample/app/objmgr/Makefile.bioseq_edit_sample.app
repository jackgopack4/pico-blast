#################################
# $Id: Makefile.bioseq_edit_sample.app 191176 2010-05-10 16:12:20Z vakatov $
#################################

REQUIRES = objects 

APP = bioseq_edit_sample
SRC = bioseq_edit_sample file_db_engine

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LOADER_PATCHER = ncbi_xloader_patcher

LIB = $(LOADER_PATCHER) $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
### END COPIED SETTINGS

WATCHERS = vasilche
