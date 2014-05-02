# $Id: Makefile.igblastn.app 375099 2012-09-17 16:06:43Z vakatov $

APP = igblastn
SRC = igblastn_app
LIB_ = $(BLAST_INPUT_LIBS)  xalgoalignutil xqueryparse $(BLAST_LIBS) $(OBJMGR_LIBS) 
LIB = blast_app_util igblast $(LIB_:%=%$(STATIC))

# De-universalize Mac builds to work around a PPC toolchain limitation
CFLAGS   = $(FAST_CFLAGS:ppc=i386)
CXXFLAGS = $(FAST_CXXFLAGS:ppc=i386)
LDFLAGS  = $(FAST_LDFLAGS:ppc=i386)

LIBS = $(CMPRS_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin

WATCHERS = camacho madden maning fongah2
