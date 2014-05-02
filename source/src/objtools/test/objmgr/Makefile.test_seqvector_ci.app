#################################
# $Id: Makefile.test_seqvector_ci.app 173093 2009-10-14 16:24:46Z vakatov $
# Author:  Eugene Vasilchenko (vasilche@ncbi.nlm.nih.gov)
#################################

# Build object manager test application "test_objmgr"
#################################


APP = test_seqvector_ci
SRC = test_seqvector_ci
LIB = $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD = run_sybase_app.sh test_seqvector_ci /CHECK_NAME=test_seqvector_ci
CHECK_TIMEOUT = 500

WATCHERS = grichenk
