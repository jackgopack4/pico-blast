# $Id: Makefile.subcheck.app 207471 2010-10-06 15:00:04Z badrazat $

APP = subcheck
SRC = read_blast_result tbl read_blast_result_lib read_tag_map \
      read_parents read_trna read_blast read_rrna collect_simple \
      overlaps missing copy_loc problems locations \
      analyze fit_blast match shortcuts short_proteins

# Aaron Ucko suggested
LIB  = xobjutil submit $(SOBJMGR_LIBS)
# LIB  = submit seqset $(SEQ_LIBS) pub medline biblio general xobjutil xobjmgr xser xutil xncbi

LIBS = $(DL_LIBS) $(ORIG_LIBS)

REQUIRES = objects

WATCHERS = badrazat
