#################################
# $Id: Makefile.test_relloc.app 191176 2010-05-10 16:12:20Z vakatov $
# Author:  Aaron Ucko (ucko@ncbi.nlm.nih.gov)
#################################

# Build relative-location-computation test application "test_relloc"
#################################


APP = test_relloc
SRC = test_relloc
LIB = xobjutil $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = ucko
