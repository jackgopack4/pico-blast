// PicoLinux.h
// author: Greg Edvenson

// This is a more mnimal version than the older version
// where possible things should really be in the equvalent windows replacement header not here
//

#if defined(POSIX)
#ifndef _PICOLINUX_H_
#define _PICOLINUX_H_

#if defined(_INC_TRACE_)
#warning "linux.h"
#endif
#ifndef __POSIX__
	#define __POSIX__
#endif
/*
#ifndef EXCLUDE_DBG
	#define EXCLUDE_DBG 1
#endif
*/
#ifndef LINUX_UNIMPL
	#define LINUX_UNIMPL 1
#endif
#ifndef _GNU_SOURCE
	#define _GNU_SOURCE
#endif
#define LINUX_FIXME	0				    // /dhl/ force failed asserts for unimplimented code.
//
// #include <stdint.h>                  // -removed pending testing. may be necessary for linux. -gme
#ifndef __KERNEL__
    #include <ctype.h>
    // #include <sys/types.h>	        // this seems to suck in all kinds of parts of the standard c library
    #include <sys/stat.h>
    #include <string.h>
    #include <glob.h>
    #include <stdio.h>
    #include <unistd.h>
    #include <syslog.h>
#endif
#include <stdarg.h>
#include <sys/time.h>
#include <dlfcn.h>

#ifndef ASSERT
	#ifdef _DEBUG
		#define ASSERT		assert // warning: on windows, the does a debugbreak. should we do that instead?
		#define _ASSERTE	assert
	#else
		#define ASSERT		((void) 0)
		#define ASSERTE		((void) 0)
	#endif // _DEBUG
#endif // ASSERT
// note: PATH_MAX is not the sum of MAX_FNAME, MAX_EXT, etc
#define _MAX_PATH	PATH_MAX
#define _MAX_FNAME	PATH_MAX
#define _MAX_EXT	PATH_MAX // since there's nothing special about the chars after the last '.'
// #define INT_MAX     65656
/***************
 *  TYPES      *
 ***************/
#ifndef BOOL
//    typedef int                 BOOL;
#endif
#ifndef __KERNEL__
#if !defined(uint8_t)
    typedef unsigned char           uint8_t;
#endif
#if !defined(uint16_t)
    typedef unsigned short          uint16_t;
#endif
#if !defined(uint32_t)
    typedef unsigned int            uint32_t;
#endif
#if !defined(int32_t)
    typedef int                     int32_t;
#endif
#if !defined(uint64_t)
    #ifdef __LP64__
        #ifdef DARWIN
            typedef unsigned long long  uint64_t;
        #else
            typedef unsigned long       uint64_t;
        #endif
    #else
        typedef unsigned long long      uint64_t;
    #endif
#endif
#if !defined(int64_t)
    #ifdef __LP64__
        #ifdef DARWIN
            typedef long long int       int64_t;
        #else
            typedef long                int64_t;
        #endif
    #else
        typedef long long               int64_t;
    #endif
#endif
#endif

/************************
 * Structs, etc.        *
 ************************/
/*********************
 *    FUNCTIONS      *
 *********************/
#if !defined(EXCLUDE_DBG) || defined(PICO_DEBUG)
	// void TRACE(const char* fmt, ...);	// prints to stderr
    #ifdef __KERNEL__
        #define TRACE(format, arg...) printk(KERN_DEBUG format , ## arg)
    #else
        #define TRACE(format, arg...) syslog(LOG_INFO, format , ## arg)
        #define DbgPrint(format, arg...) syslog(LOG_INFO, format , ## arg)
    #endif
#else
	#define TRACE(...)	    ((void)0)
	#define DbgPrint(...)	((void)0)
#endif
#define MessageBeep(x)	// the fact that is defined as nothing is a _feature_, right? :)

#define _isnan(x)	isnan(x)
// fixme: implement this.
// the problem with implementing this is that there is no unified function for errors.
//   there's errno (a var) and strerror for system and libc errors, and dlerror for errors in dlopen/dlsym, etc.
// also, it's not cleared if there's no error. ie - it's only valid if the last function indicated an error (probably by its return val)
// maybe every single wrapper function will have to clear this if it succeeds

// we might want to wait for the user to press a key after these
//#define MessageBox(window, msg, caption, style) fprintf(stderr, "MessageBox: %s: %s\n", caption, msg)
#define AfxMessageBox(str, ...)	fprintf(stderr, "AfxMessageBox: %s\n", str)
// fixme: this is just a dummy. it always returns false (meaning the addr is ok)
// BOOL IsBadReadPtr(const void* p, unsigned int size);


#if defined(NEED_STRNICMP)
int strnicmp(const char *s1, const char *s2, size_t len);
#else
#define strnicmp    strncasecmp
#endif


#if defined(NEED_STRICMP)
int stricmp(const char *s1, const char *s2);
#else
#define stricmp     strcasecmp
#endif

#define _vsnprintf      vsnprintf
#define _snprintf   snprintf
// #define _strnicmp       strnicmp
#define _strnicmp       strncasecmp
#define _strlwr         strlwr
#define _stricmp        stricmp
#define OutputDebugString     printf
#undef int3
#if defined(PICO_DEBUG) //{
#define int3()           asm ("int $3")
#else
#define int3()          {}
#endif

#if defined(PICO_DEBUG) && defined(dhlii) //{
#define dhlii_int3()    asm ("int $3")
#else
#define dhlii_int3()   {}
#endif

#define CWinApp 		int
#define HINSTANCE       void *
typedef unsigned long LONG_PTR;
typedef unsigned long UINT_PTR;
#define GetProcAddress dlsym

#define HAVE_SE_XLAT true

#if defined(HAVE_SE_XLAT)
#define _se_translator_function int*
#define _se_translator_function int*
#define _set_se_translator(TimerException) 0
#define SetErrorMode(x) 0
#endif

#define MessageBox(window, msg, caption, style) fprintf(stderr, "MessageBox: %s: %s\n", caption, msg)
#ifndef __KERNEL__
    #include "windows.h"
    #define _tmain main
#endif

#define __cdecl

int memicmp(void *a, void *b, int len);
    #undef OSNAME
#if defined(OPENBSD)
    #define lseek64 lseek
    #define OSNAME "OpenBSD"
#elif defined(DARWIN)
    #define lseek64 lseek
    #define OSNAME "Darwin"
    #include <sys/syslimits.h>
#else
    #define OSNAME "Linux"
    #include <linux/limits.h>
#endif

/******************************
 * CRITICAL_SECTION imitation *
 ******************************/
// this is fully functional. ie - no lost functionality when we move to linux

#include <pthread.h>
typedef	pthread_mutex_t	CRITICAL_SECTION;

void InitializeCriticalSection	(CRITICAL_SECTION *csP);
void DeleteCriticalSection		(CRITICAL_SECTION *csP);
void EnterCriticalSection		(CRITICAL_SECTION *csP);
int  TryEnterCriticalSection	(CRITICAL_SECTION *csP);
void LeaveCriticalSection		(CRITICAL_SECTION *csP);

#define ExitThread(a)		0	// success


// fixme: implement this.
// the problem with implementing this is that there is no unified function for errors.
//   there's errno (a var) and strerror for system and libc errors, and dlerror for errors in dlopen/dlsym, etc.
// also, it's not cleared if there's no error. ie - it's only valid if the last function indicated an error (probably by its return val)
// maybe every single wrapper function will have to clear this if it succeeds
#if !defined(PICO_WIDGETS)
// #define GetLastError()	0
#define Sleep(t)        usleep(t * 1000)
#endif
#define MAKELANGID(a, b)  0

char * _strlwr(char* str);
#define GetCurrentDirectory(size,dir) getcwd(dir,size)
#define _getcwd getcwd
#define _unlink unlink
#define getch() 0
//#define ESC 0x1b

// according to MSDN this is defined in io.h
long _get_osfhandle( int fd );

const char
*Win2PosixPath(const char* path, bool check /* = true */, bool lowercase /* = true */) ;

#endif // _PICOLINUX_H_
#endif
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
