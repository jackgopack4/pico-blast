#################################
# $Id: Makefile.test_source_mod_parser.app 390244 2013-02-26 15:11:56Z kornbluh $
#################################

APP = test_source_mod_parser
SRC = test_source_mod_parser

LIB = xobjreadex $(OBJREAD_LIBS) xobjutil $(SOBJMGR_LIBS)
LIBS = $(DL_LIBS) $(ORIG_LIBS)

WATCHERS = ucko kornbluh
