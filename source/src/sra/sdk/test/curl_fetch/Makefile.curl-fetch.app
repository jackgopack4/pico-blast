# $Id: Makefile.curl-fetch.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = curl-fetch
SRC = curl-fetch

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp vfs kurl srapath krypto kfg kfs ksproc klib $(Z_LIB)
# ktst?
LIBS = $(SRA_SDK_SYSLIBS) $(NETWORK_LIBS) $(ORIG_LIBS)

REQUIRES = CURL
