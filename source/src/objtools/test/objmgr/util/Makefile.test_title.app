#################################
# $Id: Makefile.test_title.app 191176 2010-05-10 16:12:20Z vakatov $
# Author:  Aaron Ucko (ucko@ncbi.nlm.nih.gov)
#################################

# Build title-computation test application "test_title"
#################################


APP = test_title
SRC = test_title
LIB = xobjutil $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = ucko
