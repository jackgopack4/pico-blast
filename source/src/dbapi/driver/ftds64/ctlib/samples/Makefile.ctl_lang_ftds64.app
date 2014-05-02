# $Id: Makefile.ctl_lang_ftds64.app 372543 2012-08-20 14:33:09Z ucko $

APP = ctl_lang_ftds64
SRC = ctl_lang_ftds64 dbapi_driver_sample_base_ftds64

LIB  = ncbi_xdbapi_$(ftds64)$(STATIC) $(FTDS64_CTLIB_LIB) dbapi_driver$(STATIC) $(XCONNEXT) xconnect xncbi
LIBS = $(FTDS64_CTLIB_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS) $(DL_LIBS)

CPPFLAGS = -DFTDS_IN_USE -I$(includedir)/dbapi/driver/ftds64 $(FTDS64_INCLUDE) $(ORIG_CPPFLAGS)

CHECK_REQUIRES = connext in-house-resources
# CHECK_CMD = run_sybase_app.sh ctl_lang_ftds64
CHECK_CMD = run_sybase_app.sh ctl_lang_ftds64 -S DBAPI_MS_TEST /CHECK_NAME=ctl_lang_ftds64 -S MS_TEST
CHECK_CMD = run_sybase_app.sh ctl_lang_ftds64 -S DBAPI_SYB_TEST -v 50 /CHECK_NAME=ctl_lang_ftds64 -S SYB_TEST -v 50
CHECK_CMD = run_sybase_app.sh ctl_lang_ftds64 -S DBAPI_SYB155_TEST -v 50 /CHECK_NAME=ctl_lang_ftds64 -S SYB155_TEST -v 50

WATCHERS = ucko
