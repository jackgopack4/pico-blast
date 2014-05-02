# $Id: Makefile.cgi2rcgi.app 198974 2010-07-29 20:09:01Z kazimird $

# Build test CGI application "cgi_tunnel2grid"
#################################

APP = cgi2rcgi
SRC = cgi2rcgi

LIB = xconnserv xthrserv xcgi xhtml xregexp $(PCRE_LIB) xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(PCRE_LIBS) $(ORIG_LIBS)

WATCHERS = kazimird
