# $Id: Makefile.convert_seq.app 374920 2012-09-14 14:16:47Z kornbluh $

APP = convert_seq
SRC = convert_seq
LIB = $(XFORMAT_LIBS) xalnmgr gbseq xobjutil $(OBJREAD_LIBS) tables submit \
      xregexp $(PCRE_LIB) $(OBJMGR_LIBS)

LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin

WATCHERS = ucko
