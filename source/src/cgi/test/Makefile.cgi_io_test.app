# $Id: Makefile.cgi_io_test.app 184376 2010-02-26 17:16:17Z ivanov $

APP = cgi_io_test
SRC = cgi_io_test

LIB = xcgi xutil xncbi

## ...or, for FastCGI:
#
# LIB = xfcgi xutil xncbi
# LIBS = $(FASTCGI_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

WATCHERS = grichenk
