#ifndef _INC_TCHAR
#define _INC_TCHAR

#ifdef  __cplusplus
extern "C" {
#endif

#ifndef __TCHAR_DEFINED
typedef char     _TCHAR;
typedef char     _TSCHAR;
typedef char     _TUCHAR;
typedef char     _TXCHAR;
typedef int      _TINT;
#define __TCHAR_DEFINED
#endif

#ifndef _TCHAR_DEFINED
//#if     !__STDC__
typedef char     TCHAR;
//#endif
#define _TCHAR_DEFINED
#endif


/* Program */

#define _tmain      main
#define _tWinMain   main
#define _tenviron   environ
#define __targv     argv

#include <string.h>

#define _TEOF       EOF
#define __T(x)      x


#ifdef  __cplusplus
}   /* ... extern "C" */
#endif

#endif  /* _INC_TCHAR */
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
