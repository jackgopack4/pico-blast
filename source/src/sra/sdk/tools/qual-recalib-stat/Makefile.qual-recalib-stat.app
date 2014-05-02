# $Id: Makefile.qual-recalib-stat.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = qual-recalib-stat
SRC = namelist_tools progressbar num-gen context columns ref_exclude \
      spot_position stat_mod_2 reader writer qual-recalib-stat

LIB = kapp align-reader$(DLL) $(UPDATE_SCHEMA_LIBS) wvdb wkdb vfs kurl \
      srapath ksrch$(DLL) krypto kfg kfs kproc klib judy $(BZ2_LIB) $(Z_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
