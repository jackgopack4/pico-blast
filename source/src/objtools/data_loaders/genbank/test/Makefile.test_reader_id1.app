# $Id: Makefile.test_reader_id1.app 191176 2010-05-10 16:12:20Z vakatov $



APP = test_reader_id1
SRC = test_reader_id1
LIB = $(OBJMGR_LIBS) $(GENBANK_READER_ID1_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = vasilche
