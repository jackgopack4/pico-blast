#################################
# $Id: Makefile.test_checksum.app 173093 2009-10-14 16:24:46Z vakatov $

APP = test_checksum
SRC = test_checksum
LIB = xutil xncbi

CHECK_CMD = test_checksum -selftest /CHECK_NAME=test_checksum

WATCHERS = vasilche
