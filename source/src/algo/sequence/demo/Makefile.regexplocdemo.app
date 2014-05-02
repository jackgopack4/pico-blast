# $Id: Makefile.regexplocdemo.app 208175 2010-10-14 16:52:45Z serovav $

WATCHERS = clausen

SRC = regexplocdemo
APP = regexplocdemo

CPPFLAGS = $(ORIG_CPPFLAGS) $(PCRE_INCLUDE)
CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

LIB = xalgoseq xalnmgr tables xregexp $(PCRE_LIB) xobjutil taxon1 $(OBJMGR_LIBS)

LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
