#################################
# $Id: Makefile.test_vmerge.app 309838 2011-06-28 17:01:05Z vakatov $
# Author:  Anatoliy Kuznetsov
#################################

WATCHERS = kuznets

APP = test_vmerge
SRC = test_vmerge
LIB = xalgovmerge xutil xncbi

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(FAST_LDFLAGS)

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)


