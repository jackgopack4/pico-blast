# $Id: Makefile.helicos-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = helicos-load
SRC = pstring common-xml experiment-xml run-xml loader-file loader-fmt \
      sra-writer loader writer-helicos helicos-fmt

LIB = wsradb sraschema wsraxf$(DLL) kapp wvxf$(DLL) wvdb wkdb vfs srapath kurl \
      krypto kfg load kfs ksrch kxml kxfs kq kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(LIBXML_STATIC_LIBS) $(ICONV_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
