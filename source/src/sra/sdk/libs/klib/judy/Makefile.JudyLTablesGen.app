# $Id: Makefile.JudyLTablesGen.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = JudyLTablesGen
SRC = JudyTablesGen_w

CPPFLAGS = -I$(srcdir) -I$(srcdir)/.. $(SRA_INCLUDE) \
           $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
