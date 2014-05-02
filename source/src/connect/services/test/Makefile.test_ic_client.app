# $Id: Makefile.test_ic_client.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = test_ic_client
SRC = test_ic_client
LIB = ncbi_xcache_netcache xconnserv xthrserv xconnect xutil xncbi

LIBS = $(NETWORK_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_REQUIRES = in-house-resources
CHECK_CMD = test_ic_client -service NC_UnitTest blobs

WATCHERS = kazimird gouriano
