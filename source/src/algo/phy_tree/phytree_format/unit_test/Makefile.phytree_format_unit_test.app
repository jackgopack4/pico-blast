APP = phytree_format_unit_test
SRC = phytree_format_unit_test

LIB = xalgoalignnw phytree_format xalgophytree fastme xalnmgr biotree \
      taxon1 test_boost tables $(OBJREAD_LIBS) xobjutil $(OBJMGR_LIBS)

LIBS = $(NETWORK_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CXXFLAGS = $(FAST_CXXFLAGS)
LDFLAGS  = $(FAST_LDFLAGS)

CPPFLAGS = $(ORIG_CPPFLAGS) $(BOOST_INCLUDE)

CHECK_CMD = phytree_format_unit_test
CHECK_COPY = data

WATCHERS = blastsoft
