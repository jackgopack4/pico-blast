/* =============================================================================
    File: pico_types.h. Version 4.0.1.3. Sep 15, 2007.

    This file contains various types used throughout the pico software and some
    compatibility definitions between MSdev and Linux.
   =============================================================================
*/

#ifndef _PICOTYPES_H_
#define _PICOTYPES_H_

#if defined(POSIX) //{
    #if !defined(__KERNEL__) && !defined(_KERNEL)
	    #include "linux.h"
    #endif
#else
    #ifdef _MSC_VER
        #pragma warning(disable:4793)       //warning about vararg.
        #ifndef _WIN32_WINNT                //proxy for called from Pico2k project
            #include <windows.h>
            #undef Yield
        #endif
    #endif
#endif

//****************************************
// this is just a workaround for MS typenames, and not pico-specific

#ifndef NULL
    #define NULL    0
#endif

// non-ms types when we're in windows
// gme: please leave the !LINUX in here to make kernel modules work without defining POSIX
// dhl: building a linux kernel module should always define __KERNEL__
//      building OpenBSD kernel code always defines _KERNEL
#if !defined(int32_t) && !defined(POSIX) && !defined(__KERNEL__) && !defined(LINUX) //{
    #ifndef uint32_t
            // the __* types can't be automatically cast to an "equivalent" type like __int8 -> char!!!!!!!!!!!
            // xxx - figure out a way to make these sizes portable between 32 and 64-bit
            typedef unsigned char           uint8_t;
            typedef unsigned short          uint16_t;
            typedef unsigned int            uint32_t;
        #ifdef _MSC_VER //{
            typedef unsigned __int64        uint64_t;
        #else
            typedef unsigned long long      uint64_t;
        #endif // }_MSC_VER
    #endif // !uint32_t
    #ifdef _MSC_VER
        typedef signed   __int8         int8_t;
        typedef signed   __int16        int16_t;
        typedef signed   __int32        int32_t;
        typedef signed   __int64        int64_t;
    #else
        typedef signed long long        int64_t;
    #endif
#endif // int32_t

// MS-style
#ifndef INT8
    typedef signed char         INT8, *PINT8;
    typedef signed short        INT16, *PINT16;
    typedef signed int          INT32, *PINT32;
    typedef unsigned char       UINT8, *PUINT8;
    typedef unsigned short      UINT16, *PUINT16;
    typedef unsigned int        UINT32, *PUINT32;
    #ifndef _MSC_VER
        //typedef int64_t           INT64, *PINT64;
        //typedef u_int64_t     UINT64, *PUINT64;
    #else
        typedef signed __int64      INT64, *PINT64;
        typedef unsigned __int64    UINT64, *PUINT64;
    #endif
#endif // INT8
#ifndef BOOL 
    typedef int                 BOOL;
#endif 
#ifndef DWORD
    typedef unsigned long       DWORD;
    typedef unsigned char       BYTE;
    typedef unsigned short      WORD;
    typedef float               FLOAT;
    typedef FLOAT               *PFLOAT;
    typedef BOOL               *PBOOL;
    typedef BOOL               *LPBOOL;
    typedef BYTE               *PBYTE;
    typedef BYTE               *LPBYTE;
    typedef int                *PINT;
    typedef int                *LPINT;
    typedef WORD               *PWORD;
    typedef WORD               *LPWORD;
    typedef long               *LPLONG;
    typedef DWORD              *PDWORD;
    typedef DWORD              *LPDWORD;
    typedef void               *LPVOID;
    typedef const void         *LPCVOID;

    typedef int                 INT;
    typedef unsigned int        UINT;
    typedef unsigned int        *PUINT;
#endif // DWORD

#ifndef INFINITY
   #define INFINITY 0x7FFFFFFF
#endif

typedef struct {uint32_t addr; uint16_t data, nu;} FLASH_CMD; //nu to ensure uniform packing

typedef uint64_t    pico_size_t;
typedef int64_t     FLASHROM_ADDR;
typedef uint32_t    pico_version_t;

#if defined(_WINDEF_)  || (defined(POSIX) && !defined(__KERNEL__)) //proxy for called from Pico.sys project
    typedef HINSTANCE   pico_dll_t;
#endif

#endif // _PICOTYPES_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
