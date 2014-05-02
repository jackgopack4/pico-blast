#################################
# $Id: Makefile.test_edit_saver.app 173093 2009-10-14 16:24:46Z vakatov $
# Author:  Maxim Didenko (didenko@ncbi.nlm.nih.gov)
#################################

APP = test_edit_saver
SRC = test_edit_saver
LIB = xobjmgr xobjutil ncbi_xloader_patcher $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD = test_edit_saver -gi 45678
CHECK_CMD = test_edit_saver -gi 21225451 

WATCHERS = vasilche
