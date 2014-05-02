# $Id: Makefile.formatguess_unit_test.app 371619 2012-08-09 16:47:32Z vasilche $

APP = formatguess_unit_test
SRC = formatguess_unit_test

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB  = test_boost xutil xncbi
LIBS = $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

WATCHERS = vakatov
