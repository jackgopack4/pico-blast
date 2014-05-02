# $Id: Makefile.wb-test-vxf.app 16076 2013-05-19 02:07:57Z ucko $

WATCHERS = ucko

APP = wb-test-vxf
SRC = wb-test-vxf wb-irzip-impl

CPPFLAGS = $(SRA_INCLUDE) $(Z_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) \
           $(ORIG_CPPFLAGS)
LIB_ = kapp ktst vdb kdb kfg vfs krypto kproc kfs klib $(Z_LIB)
LIB = $(LIB_:%=%$(FORCE_STATIC))
LIBS = $(Z_LIBS) $(DL_LIBS) $(ORIG_LIBS)

CHECK_CMD =
