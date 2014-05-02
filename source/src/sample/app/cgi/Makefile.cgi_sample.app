# $Id: Makefile.cgi_sample.app 173093 2009-10-14 16:24:46Z vakatov $

# Build test CGI application "cgi_sample"
#################################

APP = cgi_sample.cgi
SRC = cgi_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
## Use these two lines for normal CGI.
LIB = xcgi xhtml xconnect xutil xncbi
LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
## Use these two lines for FastCGI.  (No other changes needed!)
# LIB = xfcgi xhtml xconnect xutil xncbi
# LIBS = $(FASTCGI_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

## If you need the C toolkit...
# LIBS     = $(NCBI_C_LIBPATH) -lncbi $(NETWORK_LIBS) $(ORIG_LIBS)
# CPPFLAGS = $(ORIG_CPPFLAGS) $(NCBI_C_INCLUDE)
### END COPIED SETTINGS

CHECK_CMD  =
CHECK_COPY = cgi_sample.html

WATCHERS = vakatov
