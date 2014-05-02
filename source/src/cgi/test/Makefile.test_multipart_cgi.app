# $Id: Makefile.test_multipart_cgi.app 184376 2010-02-26 17:16:17Z ivanov $

APP = test_multipart.cgi
SRC = test_multipart_cgi
LIB = xcgi$(STATIC) xutil$(STATIC) xncbi$(STATIC)

WATCHERS = ucko
