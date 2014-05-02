# $Id: Makefile.hgvs2variation.app 330921 2011-08-15 19:18:30Z vakatov $


APP = hgvs2variation
SRC = hgvs2variation

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB_ = hgvs variation \
       entrez2cli entrez2 xregexp $(PCRE_LIB) xobjutil $(OBJMGR_LIBS)
LIB = $(LIB_:%=%$(STATIC))

LIBS = $(PCRE_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)
