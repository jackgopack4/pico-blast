# $Id: Makefile.illumina-load.app 16076 2013-05-19 02:07:57Z ucko $

WATCHERS = ucko

APP = illumina-load
SRC = pstring common-xml experiment-xml run-xml loader-file loader-fmt \
      sra-writer loader writer-illumina illumina-fmt

LIB = wsradb sraschema wsraxf$(DLL) kapp wvxf$(DLL) wvdb wkdb vfs srapath kurl \
      krypto kfg load kfs ksrch kxml kxfs kq kproc klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(LIBXML_STATIC_LIBS) $(ICONV_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
