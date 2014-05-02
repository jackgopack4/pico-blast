# $Id: Makefile.alnvwr.app 338012 2011-09-15 18:04:08Z ucko $


APP = alnvwr
SRC = alnvwrapp
LIB = xalnmgr xobjutil submit tables $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

WATCHERS = todorov
