/*======================================================================
 PicoDrv.h - the external interface file for calling applications

 Copyright 2006, Pico Computing, Inc.
====================================================================== */

#ifndef __PicoDrv_H
#define __PicoDrv_H
#if defined(POSIX) || defined(LINUX)
    #include "pico_drv_linux.h"
    #ifndef NO_SWSIM 
        #include "pico_drv_swsim.h"
    #endif
    #include <unistd.h>
    #define  __int64 long long
    #define PICODRV(n) PicoDrvLinux(n);
    #define _PICODRV(n,f) PicoDrvLinux((n),f);
#elif defined(WIN32)
    #include "pico_drv_win.h"
    
	#define PICODRV(n) PicoDrvWin(n);
    #define _PICODRV(n,f) PicoDrvWin(n,f);

	#define PRIX64 "llx"
	#define sleep(_sec) WDC_Sleep((_sec) * 1000 * 1000, WDC_SLEEP_NON_BUSY)
	#define getpid GetCurrentProcessId

	#include < time.h >
	
	#if defined(_MSC_VER) || defined(_MSC_EXTENSIONS)
	#define DELTA_EPOCH_IN_MICROSECS  116444736000000000Ui64
	#else
	#define DELTA_EPOCH_IN_MICROSECS  116444736000000000ULL
	#endif

	struct timezone 
	{
		int  tz_minuteswest; /* minutes W of Greenwich */
		int  tz_dsttime;     /* type of dst correction */
	};

	int gettimeofday(struct timeval *tv, struct timezone *tz);
#endif // WIN32

#endif  // __PicoDrv_H
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
/* $Id: picodrv.h 8360 2007-10-28 21:14:03Z  $ */
