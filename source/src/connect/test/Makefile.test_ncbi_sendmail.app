# $Id: Makefile.test_ncbi_sendmail.app 363395 2012-05-16 16:37:00Z lavr $

APP = test_ncbi_sendmail
SRC = test_ncbi_sendmail
LIB = connect $(NCBIATOMIC_LIB)

LIBS = $(NETWORK_LIBS) $(ORIG_LIBS)
#LINK = purify $(ORIG_LINK)

WATCHERS = lavr
