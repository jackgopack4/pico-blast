#################################
# $Id: Makefile.prosplign_demo.app 386465 2013-01-18 14:49:28Z chetvern $
#################################

WATCHERS = chetvern

APP = prosplign_demo
SRC = prosplign_demo

LIB = prosplign xalgoalignutil xobjutil \
      tables \
      $(OBJMGR_LIBS:%=%$(STATIC))

LIBS = $(CMPRS_LIBS) $(PCRE_LIBS) $(NETWORK_LIBS) \
       $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)


REQUIRES = objects
