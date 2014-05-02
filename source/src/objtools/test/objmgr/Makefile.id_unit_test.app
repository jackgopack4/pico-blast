#################################
# $Id: Makefile.id_unit_test.app 362189 2012-05-08 13:08:41Z ivanovp $
#################################

REQUIRES = dbapi FreeTDS Boost.Test.Included

APP = id_unit_test
SRC = id_unit_test
LIB = test_boost xobjutil $(OBJMGR_LIBS) \
      ncbi_xdbapi_ftds $(FTDS64_CTLIB_LIB) dbapi_driver$(STATIC)

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

LIBS = $(FTDS_LIBS) $(CMPRS_LIBS) $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

#CHECK_CMD = id_unit_test

WATCHERS = vasilche
