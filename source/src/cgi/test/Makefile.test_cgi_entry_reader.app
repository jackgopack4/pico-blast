# $Id: Makefile.test_cgi_entry_reader.app 173093 2009-10-14 16:24:46Z vakatov $

APP = test_cgi_entry_reader
SRC = test_cgi_entry_reader
LIB = xcgi xutil xncbi

CHECK_CMD = test_cgi_entry_reader.sh test_cgi_entry_reader.dat /CHECK_NAME=test_cgi_entry_reader.sh
CHECK_COPY = test_cgi_entry_reader.sh test_cgi_entry_reader.dat

WATCHERS = ucko
