#

WATCHERS = astashya

SRC = xcompareannotsdemo
APP = xcompareannotsdemo

CPPFLAGS = $(ORIG_CPPFLAGS)
CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

LIB  = xalgoseq xalnmgr ncbi_xloader_lds lds $(OBJREAD_LIBS) xobjutil taxon1 bdb \
       creaders tables xregexp $(PCRE_LIB) $(OBJMGR_LIBS)

LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS) $(BERKELEYDB_LIBS)

REQUIRES = bdb
