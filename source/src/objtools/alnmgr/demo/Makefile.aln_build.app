# $Id: Makefile.aln_build.app 338012 2011-09-15 18:04:08Z ucko $

APP = aln_build
SRC = aln_build_app
LIB = xalnmgr xobjutil submit tables $(OBJMGR_LIBS)

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

# CPPFLAGS = $(ORIG_CPPFLAGS) -pg
# LDFLAGS  = $(ORIG_LDFLAGS) -pg
# CPPFLAGS = $(ORIG_CPPFLAGS) $(NCBI_C_INCLUDE)
# CFLAGS   = $(ORIG_CFLAGS)
# CXXFLAGS = $(ORIG_CXXFLAGS)

WATCHERS = todorov
