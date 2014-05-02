#################################
# $Id: Makefile.test_objmgr_data.app 362189 2012-05-08 13:08:41Z ivanovp $
#################################

REQUIRES = dbapi FreeTDS

APP = test_objmgr_data
SRC = test_objmgr_data
LIB = $(OBJMGR_LIBS) ncbi_xdbapi_ftds $(FTDS64_CTLIB_LIB) dbapi_driver$(STATIC)

LIBS = $(FTDS_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_COPY = test_objmgr_loaders_id1.sh test_objmgr_loaders_id2.sh test_objmgr_loaders_pubseqos.sh test_objmgr_data.sh test_objmgr_data_ids.sh test_objmgr_data.id1 test_objmgr_data.id2
CHECK_CMD = test_objmgr_loaders_id2.sh test_objmgr_data_ids.sh test_objmgr_data /CHECK_NAME=test_objmgr_data
CHECK_CMD = test_objmgr_loaders_id1.sh test_objmgr_data.sh /CHECK_NAME=test_objmgr_data.sh+id1
CHECK_CMD = test_objmgr_loaders_id2.sh test_objmgr_data.sh /CHECK_NAME=test_objmgr_data.sh+id2
CHECK_CMD = test_objmgr_loaders_pubseqos.sh test_objmgr_data.sh /CHECK_NAME=test_objmgr_data.sh+pubseqos
CHECK_CMD = test_objmgr_data -prefetch

WATCHERS = vasilche
