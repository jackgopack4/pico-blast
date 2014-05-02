# $Id: Makefile.trans.app 14717 2013-03-08 15:25:05Z ucko $

WATCHERS = ucko

APP = trans
SRC = support t_al_iter t_reflist t_pl_iter t_plset_iter t_walk_1_alignment \
      tokenizer trans

CPPFLAGS = $(SRA_INCLUDE) $(SRA_INTERNAL_CPPFLAGS) $(ORIG_CPPFLAGS)
LIB = align-reader kapp vdb kdb vfs kurl srapath kfg krypto kfs kproc klib \
      $(Z_LIB) $(BZ2_LIB)
LIBS = $(SRA_SDK_SYSLIBS) $(ORIG_LIBS)

# CHECK_CMD = 1.sh /CHECK_NAME=trans
# CHECK_COPY = 1.sh
