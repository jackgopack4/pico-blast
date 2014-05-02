#################################
# $Id: Makefile.asn2asn.app 398250 2013-05-03 18:58:32Z rafanovi $
# Author:  Eugene Vasilchenko (vasilche@ncbi.nlm.nih.gov)
#################################

# Build serialization test/demo application "asn2asn"
#################################

REQUIRES = objects dbapi FreeTDS

APP = asn2asn
SRC = asn2asn

LIB  = submit ncbi_xdbapi_ftds $(FTDS_LIB) $(OBJMGR_LIBS)
LIBS = $(FTDS_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD = asn2asn.sh
CHECK_CMD = asn2asn.sh /am/ncbiapdata/test_data/objects
CHECK_COPY = asn2asn.sh ../../serial/datatool/testdata
CHECK_REQUIRES = unix in-house-resources -Cygwin
CHECK_TIMEOUT = 600

WATCHERS = gouriano
