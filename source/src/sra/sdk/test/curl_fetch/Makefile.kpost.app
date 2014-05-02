# $Id: Makefile.kpost.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kpost
SRC = kpost

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath kfg krypto kfs kproc klib $(Z_LIB)
# ktst?
LIBS = $(CURL_LIBS) $(Z_LIBS) $(DL_LIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = CURL
