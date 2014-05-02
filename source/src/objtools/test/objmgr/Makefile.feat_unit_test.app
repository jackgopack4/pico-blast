#################################
# $Id: Makefile.feat_unit_test.app 383164 2012-12-12 15:57:07Z vasilche $
#################################

REQUIRES = dbapi FreeTDS Boost.Test.Included

APP = feat_unit_test
SRC = feat_unit_test
LIB = test_boost xobjutil $(OBJMGR_LIBS) \
      ncbi_xdbapi_ftds $(FTDS64_CTLIB_LIB) dbapi_driver$(STATIC)

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIBS = $(FTDS_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD = feat_unit_test

WATCHERS = vasilche
