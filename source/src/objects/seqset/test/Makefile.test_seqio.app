# $Id: Makefile.test_seqio.app 398227 2013-05-03 18:52:51Z rafanovi $

APP = test_seqio
SRC = test_seqio

REQUIRES = Boost.Test.Included

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = test_boost seqset $(SEQ_LIBS) pub medline biblio general xser xutil xncbi

CHECK_CMD =
CHECK_REQUIRES = in-house-resources
CHECK_TIMEOUT = 300

WATCHERS = vasilche gouriano
