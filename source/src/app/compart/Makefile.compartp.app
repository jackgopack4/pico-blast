############################
# $Id: Makefile.compartp.app 386543 2013-01-18 21:13:20Z chetvern $
############################

APP = compartp
SRC = compartp

LIB = prosplign  xalgoalignutil $(BLAST_LIBS)  xqueryparse $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

