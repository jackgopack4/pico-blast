# $Id: Makefile.fcgi_sample.app 191176 2010-05-10 16:12:20Z vakatov $

# Build test CGI application "cgi_sample"
#################################

APP = fcgi_sample.fcgi
SRC = cgi_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
## Use these two lines for normal CGI.
#LIB = xcgi xhtml xconnect xutil xncbi
#LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
## Use these two lines for FastCGI.  (No other changes needed!)
LIB = xfcgi xhtml xconnect xutil xncbi
LIBS = $(FASTCGI_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

## If you need the C toolkit...
# LIBS     = $(NCBI_C_LIBPATH) -lncbi $(NETWORK_LIBS) $(ORIG_LIBS)
# CPPFLAGS = $(ORIG_CPPFLAGS) $(NCBI_C_INCLUDE)
### END COPIED SETTINGS

REQUIRES = unix

WATCHERS = vakatov
