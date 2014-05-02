# $Id: Makefile.readresult.app 208175 2010-10-14 16:52:45Z serovav $
# Author:  Lewis Y. Geer

# Build application "omssacl"
#################################

WATCHERS = lewisg gorelenk

APP = readresult

SRC = readresult

LIB = omssa seqset seq seqcode sequtil pub medline biblio general xser xregexp $(PCRE_LIB) xutil xncbi
LIBS = $(PCRE_LIBS) $(ORIG_LIBS)
