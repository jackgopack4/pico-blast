# $Id: Makefile.logs_replay.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = logs_replay
SRC = logs_replay
LIB = xconnserv xconnect xutil xncbi

LIBS = $(DL_LIBS) $(ORIG_LIBS)

#REQUIRES = MT
REQUIRES = MT Linux

WATCHERS = gouriano
