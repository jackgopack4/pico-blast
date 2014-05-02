# $Id: Makefile.Judy1TablesGen.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = Judy1TablesGen
SRC = JudyTablesGen_b

CPPFLAGS = -I$(srcdir) -I$(srcdir)/.. $(SRA_INCLUDE) \
           $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
