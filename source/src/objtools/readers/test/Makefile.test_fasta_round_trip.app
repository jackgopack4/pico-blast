#################################
# $Id: Makefile.test_fasta_round_trip.app 390244 2013-02-26 15:11:56Z kornbluh $
#################################

APP = test_fasta_round_trip
SRC = test_fasta_round_trip

LIB = $(OBJREAD_LIBS) xobjutil $(SOBJMGR_LIBS)
LIBS = $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = ucko kornbluh

CHECK_CMD = test_fasta_round_trip.sh
CHECK_COPY = test_fasta_round_trip.sh test_fasta_round_trip_data
