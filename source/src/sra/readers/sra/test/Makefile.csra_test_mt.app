#################################
# $Id: Makefile.csra_test_mt.app 391532 2013-03-08 20:03:36Z ucko $
# Author:  Eugene Vasilchenko
#################################

# Build application "csra_test_mt"
#################################

APP = csra_test_mt
SRC = csra_test_mt

LIB = test_mt $(SRAREAD_LIBS) $(SOBJMGR_LIBS) $(CMPRS_LIB)
LIBS =  $(SRA_SDK_SYSLIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects

CPPFLAGS = $(ORIG_CPPFLAGS) $(SRA_INCLUDE)

CHECK_REQUIRES = -AIX -BSD -MSWin -Solaris
#CHECK_CMD = csra_test_mt

WATCHERS = vasilche
