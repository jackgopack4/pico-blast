# $Id: Makefile.basic_sample.app 191176 2010-05-10 16:12:20Z vakatov $

APP = basic_sample
SRC = basic_sample

# new_project.sh will copy everything in the following block to any
# Makefile.*_app generated from this sample project.  Do not change
# the lines reading "### BEGIN/END COPIED SETTINGS" in any way.

### BEGIN COPIED SETTINGS
LIB = xncbi

# LIB      = xser xhtml xcgi xconnect xutil xncbi

## If you need the C toolkit...
# LIBS     = $(NCBI_C_LIBPATH) -lncbi $(NETWORK_LIBS) $(ORIG_LIBS)
# CPPFLAGS = $(ORIG_CPPFLAGS) $(NCBI_C_INCLUDE)
### END COPIED SETTINGS


WATCHERS = vakatov
