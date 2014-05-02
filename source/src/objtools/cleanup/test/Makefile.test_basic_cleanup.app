###############################
# $Id: Makefile.test_basic_cleanup.app 274296 2011-04-13 16:11:00Z kornbluh $
###############################

APP = test_basic_cleanup
SRC = test_basic_cleanup
LIB = xcleanup xregexp xobjutil submit $(OBJMGR_LIBS) $(PCRE_LIB)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

WATCHERS = bollin kornbluh
