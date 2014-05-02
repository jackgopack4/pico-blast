# $Id: Makefile.pacbio-load.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = pacbio-load
SRC = pl-context pl-tools pl-zmw pl-basecalls_cmn pl-sequence pl-consensus \
      pl-passes pl-metrics pl-regions pl-progress pacbio-load

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = kapp wsraschema$(FORCE_STATIC) wsraxf$(DLL) wvxf$(DLL) wvdb wkdb vfs \
      kurl srapath$(FORCE_STATIC) krypto kfg load kfs ksrch kdf5 kq kproc \
      klib $(Z_LIB) $(BZ2_LIB)
LIBS = $(HDF5_LIBS) $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

REQUIRES = HDF5
# unix
