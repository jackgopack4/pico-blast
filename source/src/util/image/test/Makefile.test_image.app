# $Id: Makefile.test_image.app 184358 2010-02-26 16:33:57Z ivanov $

APP  = test_image
SRC  = test_image

LIB  = ximage xncbi
LIBS = $(IMAGE_LIBS) $(ORIG_LIBS)

WATCHERS = dicuccio