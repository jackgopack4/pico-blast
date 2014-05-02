# $Id: Makefile.test_expr.app 379862 2012-11-05 20:39:35Z zakharov $

APP = test_expr
SRC = test_expr

LIB = test_boost$(STATIC) xncbi

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIBS = $(ORIG_LIBS)

REQUIRES = Boost.Test.Included

CHECK_CMD =


WATCHERS = vakatov zakharov
