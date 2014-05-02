# $Id: Makefile.odbc_lang.app 370257 2012-07-27 14:56:37Z ivanovp $

APP = odbc_lang
SRC = odbc_lang

REQUIRES = ODBC

LIB  = ncbi_xdbapi_odbc dbapi_driver $(XCONNEXT) xconnect xncbi
LIBS = $(ODBC_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CPPFLAGS = $(ODBC_INCLUDE) $(ORIG_CPPFLAGS)

CHECK_REQUIRES = in-house-resources
CHECK_COPY = odbc_lang.ini
CHECK_CMD =

WATCHERS = ucko
