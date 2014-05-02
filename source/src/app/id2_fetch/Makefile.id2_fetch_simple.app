# $Id: Makefile.id2_fetch_simple.app 180735 2010-01-12 17:03:09Z ucko $

APP = id2_fetch_simple
SRC = id2_fetch_simple
LIB = id2 seqsplit seqset $(SEQ_LIBS) pub medline biblio general \
      xser xconnect $(COMPRESS_LIBS) dbapi_driver xutil xncbi

LIBS = $(NETWORK_LIBS) $(CMPRS_LIBS) $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects dbapi

# CHECK_CMD = id2_fetch_simple -gi 3

WATCHERS = grichenk
