# $Id: Makefile.test_nc_stress_pubmed.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = test_nc_stress_pubmed
SRC = test_nc_stress_pubmed
LIB = xconnserv$(STATIC) xthrserv$(STATIC) xconnect$(STATIC) xutil$(STATIC) xncbi$(STATIC)

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = unix


WATCHERS = gouriano
