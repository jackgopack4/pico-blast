# $Id: Makefile.illumina-dump.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = illumina-dump
SRC = factory fasta_dump core illumina

LIB = sradb srapath sraschema srareader sraxf$(DLL) align-reader \
      axf$(DLL) kapp vxf$(DLL) vdb kdb vfs kurl krypto kfg kfs ksrch$(DLL) \
      kproc klib judy $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
