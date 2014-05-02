# $Id: Makefile.kqsh.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = kqsh
SRC = kqsh-print kqsh-tok kqsh-parse kqsh-alter kqsh-close kqsh-help kqsh-load \
      kqsh-open kqsh-create kqsh-show kqsh-write kqsh-kdb kqsh-vdb kqsh-sra kqsh

LIB = kapp$(FORCE_STATIC) sradb$(DLL) vdb$(DLL) kdb$(DLL) vfs$(FORCE_STATIC) \
      kurl srapath$(FORCE_STATIC) krypto$(FORCE_STATIC) kfg$(FORCE_STATIC) \
      kfs$(FORCE_STATIC) ksproc$(FORCE_STATIC) klib$(FORCE_STATIC) \
      $(Z_LIB) $(BZ2_LIB)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS) \
           -DLIBKDB=libkdb$(dll_ext) -DLIBWKDB=libwkdb$(dll_ext) \
           -DLIBVDB=libvdb$(dll_ext) -DLIBWVDB=libwvdb$(dll_ext) \
           -DLIBSRADB=libsradb$(dll_ext) -DLIBWSRADB=libwsradb$(dll_ext)

LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)
