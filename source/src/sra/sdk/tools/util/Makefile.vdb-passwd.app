# $Id: Makefile.vdb-passwd.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = vdb-passwd
SRC = vdb-passwd syspass
LIB = kapp$(FORCE_STATIC) vfs kurl srapath kfg krypto kfs \
      ksproc$(FORCE_STATIC) klib $(Z_LIB) $(BZ2_LIB)

CPPFLAGS = -I$(srcdir) $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
