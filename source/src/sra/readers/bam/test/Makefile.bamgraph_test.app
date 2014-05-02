#################################
# $Id: Makefile.bamgraph_test.app 391532 2013-03-08 20:03:36Z ucko $
# Author:  Eugene Vasilchenko
#################################

# Build application "sra_test"
#################################

APP = bamgraph_test
SRC = bamgraph_test

LIB =   bamread xobjreadex xobjutil $(OBJMGR_LIBS) $(BAM_LIBS)
LIBS =  $(SRA_SDK_SYSLIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects

CPPFLAGS = $(ORIG_CPPFLAGS) $(SRA_INCLUDE)

WATCHERS = vasilche ucko
