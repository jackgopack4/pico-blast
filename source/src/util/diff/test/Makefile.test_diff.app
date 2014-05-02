# $Id: Makefile.test_diff.app 385270 2013-01-08 16:23:52Z ivanov $

APP = test_diff
SRC = test_diff

LIB = xdiff xncbi
LIBS = $(ORIG_LIBS)
CPPFLAGS = $(ORIG_CPPFLAGS)

CHECK_COPY = testdata
CHECK_CMD = 

WATCHERS = ivanov
