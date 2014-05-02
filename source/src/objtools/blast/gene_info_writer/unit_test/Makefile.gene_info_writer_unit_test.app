# $Id: Makefile.gene_info_writer_unit_test.app 294689 2011-05-25 20:37:36Z camacho $

APP = gene_info_writer_unit_test
SRC = gene_info_writer_test

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)
CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS = $(LOCAL_LDFLAGS) $(FAST_LDFLAGS)

LIB_ = test_boost gene_info_writer gene_info xobjutil seqdb blastdb $(SOBJMGR_LIBS)
LIB = $(LIB_:%=%$(STATIC))

LIBS = $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_REQUIRES = in-house-resources
CHECK_CMD  = gene_info_writer_unit_test
CHECK_COPY = data


WATCHERS = madden camacho
