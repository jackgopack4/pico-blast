#################################
# $Id: Makefile.test_objmgr_sv.app 173093 2009-10-14 16:24:46Z vakatov $
# Author:  Eugene Vasilchenko (vasilche@ncbi.nlm.nih.gov)
#################################

# Build object manager test application "test_objmgr"
#################################

APP = test_objmgr_sv
SRC = test_objmgr_sv
LIB = $(SOBJMGR_LIBS)

LIBS = $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD = test_objmgr_sv -seed 1 -checksum c78cb2fb4d1b2926fede0945d9ae88b9 /CHECK_NAME=test_objmgr_sv

WATCHERS = vasilche
