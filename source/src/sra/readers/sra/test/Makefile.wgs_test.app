#################################
# $Id: Makefile.wgs_test.app 391532 2013-03-08 20:03:36Z ucko $
# Author:  Eugene Vasilchenko
#################################

# Build application "wgs_test"
#################################

APP = wgs_test
SRC = wgs_test

LIB =   $(SRAREAD_LIBS) $(SOBJMGR_LIBS) $(CMPRS_LIB)
LIBS =  $(SRA_SDK_SYSLIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = objects

CPPFLAGS = $(ORIG_CPPFLAGS) $(SRA_INCLUDE)

CHECK_REQUIRES = -AIX -BSD -MSWin -Solaris
CHECK_CMD = wgs_test -file AAAA -print_seq
CHECK_CMD = wgs_test -file AAAA01 -print_seq
CHECK_CMD = wgs_test -file AAAA02 -print_seq
CHECK_CMD = wgs_test -file NZ_AAAA -print_seq
CHECK_CMD = wgs_test -file NZ_AAAA01 -print_seq
CHECK_CMD = wgs_test -file ALWZ -print_seq
CHECK_CMD = wgs_test -file AINT -print_seq
CHECK_CMD = wgs_test -file AAAA01000001 -print_seq
CHECK_CMD = wgs_test -file AAAA01999999 -print_seq

WATCHERS = vasilche ucko
