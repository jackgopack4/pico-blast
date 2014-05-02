# $Id: Makefile.socket_io_bouncer.app 184358 2010-02-26 16:33:57Z ivanov $

APP = socket_io_bouncer
SRC = socket_io_bouncer
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

WATCHERS = lar
