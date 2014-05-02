#################################
# $Id: Makefile.vdb_test.app 391532 2013-03-08 20:03:36Z ucko $
# Author:  Eugene Vasilchenko
#################################

# Build application "vdb_test"
#################################

APP = vdb_test
SRC = vdb_test

LIB =   $(SRAREAD_LIBS) $(SOBJMGR_LIBS) $(CMPRS_LIB)
LIBS =  $(SRA_SDK_SYSLIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects

CPPFLAGS = $(ORIG_CPPFLAGS) $(SRA_INCLUDE)

CHECK_REQUIRES = -AIX -BSD -MSWin -Solaris
CHECK_CMD = vdb_test
CHECK_CMD = vdb_test -acc SRR035417
CHECK_CMD = vdb_test -acc SRR749060 -scan_reads

WATCHERS = vasilche ucko
