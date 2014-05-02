#################################
# $Id: Makefile.test_ncbimime.app 191176 2010-05-10 16:12:20Z vakatov $
# Author:  Eugene Vasilchenko (vasilche@ncbi.nlm.nih.gov)
#################################

# Build test application "test_ncbimime"
#################################

APP = test_ncbimime
SRC = test_ncbimime
LIB = ncbimime cdd scoremat cn3d mmdb seqset $(SEQ_LIBS) \
	pub medline medlars biblio pub general \
	xser xutil xncbi

WATCHERS = vasilche
