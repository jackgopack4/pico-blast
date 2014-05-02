# $Id: Makefile.alnmrg.app 398628 2013-05-07 16:16:55Z rafanovi $


APP = alnmrg
SRC = alnmrg

LIB = xalnmgr $(OBJREAD_LIBS) ncbi_xloader_blastdb seqdb xobjutil submit blastdb \
      tables $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_CMD  = run_sybase_app.sh alnmrg.sh /CHECK_NAME=alnmrg.sh
CHECK_COPY = alnmrg.sh data

WATCHERS = todorov
