###############################
# $Id: Makefile.test_validator.app 374920 2012-09-14 14:16:47Z kornbluh $
###############################

APP = test_validator
SRC = test_validator
LIB = xvalidate $(XFORMAT_LIBS) xalnmgr xobjutil valerr submit tables taxon3 gbseq \
      valid xregexp $(PCRE_LIB) $(OBJMGR_LIBS)

LIBS =  $(PCRE_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_CMD  = test_validator.sh
CHECK_COPY = current.prt test_validator.sh

REQUIRES = -Cygwin objects

WATCHERS = bollin
