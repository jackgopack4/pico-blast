# $Id: Makefile.python_ncbi_dbapi_test.app 386635 2013-01-22 16:28:25Z ucko $

APP = python_ncbi_dbapi_test
SRC = python_ncbi_dbapi_test

REQUIRES = PYTHON Boost.Test.Included

CPPFLAGS = $(ORIG_CPPFLAGS) $(PYTHON_INCLUDE) $(BOOST_INCLUDE)

LIB  = dbapi_driver$(STATIC) xconnect xutil xncbi test_boost
LIBS = $(PYTHON_LIBS) $(ORIG_LIBS)

CHECK_REQUIRES = unix DLL_BUILD in-house-resources
CHECK_COPY = python_ncbi_dbapi_test.ini
CHECK_TIMEOUT = 300

CHECK_CMD = python_ncbi_dbapi_test -dr ctlib -S Sybase
CHECK_CMD = python_ncbi_dbapi_test -dr dblib -S Sybase
CHECK_CMD = python_ncbi_dbapi_test -dr ftds  -S Sybase
CHECK_CMD = python_ncbi_dbapi_test -dr ftds  -S MsSql
CHECK_CMD = python_ncbi_dbapi_test -dr odbc  -S MsSql


WATCHERS = ucko
