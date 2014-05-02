#################################
# $Id: Makefile.test_line_reader.app 173093 2009-10-14 16:24:46Z vakatov $

APP = test_line_reader
SRC = test_line_reader
LIB = xutil xncbi

CHECK_CMD = test_line_reader -selftest /CHECK_NAME=test_line_reader

WATCHERS = ucko
