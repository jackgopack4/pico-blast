#################################
# $Id: Makefile.seqvec_bench.app 191176 2010-05-10 16:12:20Z vakatov $
#################################


APP = seqvec_bench
SRC = seqvec_bench
LIB = test_mt $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


WATCHERS = dicuccio
