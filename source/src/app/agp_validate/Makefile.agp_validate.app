# $Id: Makefile.agp_validate.app 371965 2012-08-14 12:45:11Z ludwigf $

APP = agp_validate
SRC = agp_validate AltValidator AgpFastaComparator

LIB  = ncbi_xloader_lds2 lds2 $(OBJREAD_LIBS) xobjutil taxon1 entrez2cli \
       entrez2 submit sqlitewrapp $(OBJMGR_LIBS)
LIBS = $(SQLITE3_STATIC_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) \
       $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects -Cygwin SQLITE3
CXXFLAGS = $(ORIG_CXXFLAGS)
# -Wno-parentheses

WATCHERS = kornbluh sapojnik
