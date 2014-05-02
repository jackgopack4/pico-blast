# $Id: Makefile.test_bam_loader.app 391532 2013-03-08 20:03:36Z ucko $

APP = test_bam_loader
SRC = test_bam_loader

REQUIRES = Boost.Test.Included

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIB = ncbi_xloader_bam bamread $(BAM_LIBS) xobjreadex xobjutil test_boost $(OBJMGR_LIBS)

LIBS = $(SRA_SDK_SYSLIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

CHECK_COPY = mapfile test_bam_loader.ini
CHECK_CMD = test_bam_loader
CHECK_REQUIRES = -AIX -BSD -Solaris

WATCHERS = vasilche ucko
