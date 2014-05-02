# $Id: Makefile.hello.app 256600 2011-03-07 16:20:36Z mcelhany $
# Author:  Lewis Geer

# Build CGI application "HELLO"
# NOTE:  see in "Makefile.fasthello.app" for how to build it as Fast-CGI
#################################

WATCHERS = grichenk

APP = hello.cgi
SRC = helloapp hellores hellocmd

### BEGIN COPIED SETTINGS
LIB = xhtml xcgi xutil xncbi
### END COPIED SETTINGS

CHECK_CMD =
