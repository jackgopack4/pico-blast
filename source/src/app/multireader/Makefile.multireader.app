#################################
# $Id: Makefile.multireader.app 398626 2013-05-07 16:16:43Z rafanovi $
# Author:  Frank Ludwig
#################################

# Build application "multireader"
#################################

APP =  multireader
SRC =  multireader
LIB =  xalgophytree biotree fastme xalnmgr tables xobjreadex $(OBJREAD_LIBS) xobjutil \
       $(SOBJMGR_LIBS)
LIBS = $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects algo -Cygwin


WATCHERS = ludwigf
