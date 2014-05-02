# $Id: Makefile.test_feat_tree.app 337949 2011-09-15 15:41:32Z vasilche $

APP = test_feat_tree
SRC = test_feat_tree

CPPFLAGS = $(ORIG_CPPFLAGS)

LIB = xobjutil $(OBJMGR_LIBS)
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_COPY = test_feat_tree.sh
CHECK_CMD = test_feat_tree.sh
CHECK_REQUIRES = unix in-house-resources -Cygwin

WATCHERS = vasilche
