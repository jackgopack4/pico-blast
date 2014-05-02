# $Id: Makefile.sra-sort.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = sra-sort
SRC = caps mem membank paged-membank paged-mmapbank except idx-mapping \
      map-file col-pair row-set simple-row-set mapping-row-set \
      sorting-row-set meta-pair dir-pair tbl-pair db-pair glob-poslen \
      poslen-col-pair ref-alignid-col buff-writer id-mapper-col \
      capture-first-half-aligned csra-tbl csra-pair run sra-sort \
      xcheck-ref-align

LIB = kapp $(UPDATE_SCHEMA_LIBS) align-reader$(DLL) ksrch$(DLL) \
      sraschema$(FORCE_STATIC) wvdb wkdb vfs srapath kurl krypto kfg kfs \
      kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)

# REQUIRES = unix
