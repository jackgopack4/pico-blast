# $Id: Makefile.seqalign_unit_test.app 178693 2009-12-15 19:37:13Z vakatov $

APP = seqalign_unit_test
SRC = seqalign_unit_test

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = $(SEQ_LIBS) pub medline biblio general xser xutil test_boost xncbi

LIBS = $(DL_LIBS) $(ORIG_LIBS)
LDFLAGS = $(FAST_LDFLAGS)

REQUIRES = objects

CHECK_CMD = seqalign_unit_test
CHECK_COPY = data

WATCHERS = camacho
