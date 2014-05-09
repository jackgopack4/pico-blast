/* =============================================================================
    File: always.h. Version 4.0.1.3. Sep 15, 2007.
    This file contains standard definitions used throughout the Pico system.
   ============================================================================= */

#ifndef _ALWAYS_H_
#define _ALWAYS_H_
#include <stdlib.h> // for _MAX_PATH
#pragma warning(disable:4996)

#if defined(WIN32)
#include "utils.h"
#endif

//#include <afxmt.h> // critical section stuff
class cGString;
#include <pico_types.h>
#include <PicoAlways.h>
#include <sys/types.h>
#include <string.h>

#define STRMAX 0x7fffffff			/// should work for int and unsigned
/*
 *strlcat() and strlcpy() are for real, They really test for buffer overruns
  and truncate on overrun.
  _snprintf() _strlcat() and _strlcpy() are just replacements 
  that duplicate snprintf() strcat() and strcpy()
  use of any of these requires adding source/string.cpp to your project.
  /dhl/ 

*/
//size_t strlcpy (char *dst, const char *src, size_t size);
//size_t strlcat (char *dst, const char *src, size_t size);
//size_t _strlcpy (char *dst, const char *src, size_t size);
//size_t _strlcat (char *dst, const char *src, size_t size);
//int _snprintf(char * buf, size_t size, const char *fmt, ...);

// miscellaneous stupidities
#if defined(_WIN32)
    #define SIZE_FN     _MAX_PATH
    #define PATH_MAX    _MAX_PATH
    #define isWin()     1
#else
    #define SIZE_FN     PATH_MAX
    #define O_BINARY    0       // for open()
    #define isWin()     0
#endif

#ifdef _DEBUG
   #define DEBUG_LETTER     "D"
#else
   #define DEBUG_LETTER     ""
#endif

#if defined(_DEBUG) && !defined(DASSERT) && defined(_WIN32)
   #define DASSERT(condition) {if (!(condition)) ::MessageBox(NULL, "assert", #condition, MB_OK);}
#else
   inline void DASSERT(int) {}
#endif

extern "C" pico_version_t PicoVersion;
inline pico_version_t PicoMakeVersion(uint8_t major, uint8_t minor, uint8_t revision, uint8_t counter)
   {return (((pico_version_t) major)    << 24) |
           (((pico_version_t) minor)    << 16) |
           (((pico_version_t) revision) <<  8) |
           ((pico_version_t)  counter);
   }

#define ENTRY_POINT             //signals a routine that is called from outside current module.
#define ENTRY                   //signals a routine that is called from outside current module.
#define ALLOCATED_CHAR char     //routine allocates memory arena returned
#define ALPHABETICS             "ABCDEFGHIJKLMNOPQRSTUVWXYZ" "abcdefghijklmnopqrstuvwxyz"
#define NUMBERS                 "0123456789"
#define HEXNUMBERS              NUMBERS "ABCDEFabcdef"
#define ALPHANUMERICS           ALPHABETICS NUMBERS
#ifndef HOWMANY
   #define HOWMANY(a) (sizeof(a)/sizeof((a)[0]))
#endif

// this zaps some multi-byte character constant warnings.
// it SHOULD be portable - depending on the source of the ASCII value
#define STR2INT2(string) ((string[0] << 8)  + string[1] )
#define STR2INT3(string) ((string[0] << 16) + (string[1] << 8) + string[2])

#if defined(POSIX)
    #define isPosix()   1
#else
    #define isPosix()   0
#endif
#ifdef PICO_WIDGETS
    #if !defined(TRACE) && defined(_WIN32)  // /dhl/ leave TRACE alone in Linux
        #define TRACE   ::wxLogDebug
    #endif
    #include <wx/wx.h>
    //#include <stdint.h>
    #ifndef ASSERT
        #define ASSERT  wxASSERT
    #endif
 #else
    #if defined(_WIN32)  // /dhl/ leave TRACE alone in Linux
        #undef TRACE
        void TRACE(const char*,...);
    #endif
#endif

#ifdef INCLUDE_XML
    #include <msxml2.h>
#endif

#define DHLII_STOP_ONCE
#if defined(_DEBUG) || defined(PICO_DEBUG) //{ /dhl/ _DEBUG turns on too much
    #if defined(_WIN32)
        #define int3()           __asm{int 3}
    #endif
                                         //would hang out of proc server sometimes, if debugger not present
    #define STOP_ONCE {static int _stopper_;if (DEBUGGER_PRESENT && _stopper_++==0) int3();}
    #if defined(POSIX) && (defined(dhlii) || defined(openbsd))
        #undef DHLII_STOP_ONCE
        #define DHLII_STOP_ONCE {static int _stopper_;if (DEBUGGER_PRESENT && _stopper_++==0) int3();}
    #endif
#else //}...{
    #if defined(_WIN32)
        #define int3() {}
    #endif
    #define DEBUGGER_PRESENT false //a debugger wont be present in release mode...
    #define STOP_ONCE
#endif //}

// /dhl/ should these be in BOTH PicoAlways.h and always.h ?
#define BUG_ELF_LOAD          0x00000001 //debug flags in monitor.sys
#define BUG_ELF_PROGRAM       0x00000002 //             "     n/u
#define BUG_ELF_RFU           0x000FFFF0 //             "     flags reserved for users.
//driver debug flags are in   0x0FF00000 bits
#define BUG_DRIVER_SUMMARY    0x00200000 //debug of Pico.SYS
#define BUG_DRIVER_INTERRUPT  0x00400000 //       "
#define BUG_DRIVER_POWER      0x00800000 //       "
#define BUG_DRIVER_DETAIL     0x01000000 //       "
#define BUG_DRIVER_JTAG       0x02000000 //       "
#define BUG_DRIVER_KEYHOLE    0x04000000 //       "
#define BUG_DRIVER_BM         0x08000000 //       "
//general control bits are in 0xF0000000 bits
#define BUG_PERSISTENT        0x20000000 //saves value in registry (not implemented or used).
#define BUG_REPLACE           0x40000000 //flag for PicoXface::SetDebugFlags() to force replace rather than and/or
#define BUG_QUIET             0x80000000 //monitor.elf does not report setting.

bool Isalpha         (char a);
bool Isdigit         (char a);
cGString HexOf       (const void* src, int size, int lineSize = 32, int blockSize = 4);
int    Anumber       (const char *msg, char **ppp=NULL, int base=10);
int64_t Anumber64    (const char *msg, char **ppp=NULL, int base=10);
char  *Endof         (const char *s);

inline int Min       (int a, int b) {return a < b ? a : b;}
inline int Max       (int a, int b) {return a > b ? a : b;}
inline uint64_t Max64(uint64_t a, uint64_t b) {return a > b ? a : b;}
inline uint64_t Min64(uint64_t a, uint64_t b) {return a < b ? a : b;}

void   RegisterErrorPosition(const char *bolP);
void   RegisterErrorBase  (const char *bTextP, const char *eTextP);
int    ResolveFileName    (char *fileOut, const char *fileIn, const char *drctryName=NULL);
#define ltrim(a) (a+strspn(a," "))
int    strBegins          (const char *a, const char *b);
int    strEnds            (const char *a, const char *b);
char  *strBeginsIgnore_   (const char *sourceP, const char *targetP);
char  *strDupl            (const char *sourceP, int len=-1);
char  *strnDupl           (const char *sourceP, int len);
char  *stristr            (const char *source, const char *target);
char  *strLtrim           (char *source);
char  *strLtrimx          (char *source, char *what);
char  *strRtrim           (char *source);
char  *strRtrimx          (char *source, char *what);
const char  *strSpaces          (int);
char  *strXlat            (char *source, char *from, char *to);
char  *strLtrimLines      (char *source);
char  *strRtrimLines      (char *source);
char  *strReplace         (char *strP, char *findP, char *repP, bool wholeWord = false);
int    strScore           (const char *pp, const char *qq, bool bRejectBadMatch = false);
int64_t strtol64          (const char *pp, char **ppP, int base);


///gme to dhlii: I imagine we'll need an if-not-obsd around these funcs.
/*
 * Copyright (c) 1998 Todd C. Miller <Todd.Miller@courtesan.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
/*
 * Copy src to string dst of size siz.  At most siz-1 characters
 * will be copied.  Always NUL terminates (unless siz == 0).
 * Returns strlen(src); if retval >= siz, truncation occurred.
 */
static inline size_t
_strlcpy(char *dst, const char *src, size_t siz)
{
    char *d = dst;
    const char *s = src;
    size_t n = siz;

    /* Copy as many bytes as will fit */
    if (n != 0) {
        while (--n != 0) {
            if ((*d++ = *s++) == '\0')
                break;
        }
    }

    /* Not enough room in dst, add NUL and traverse rest of src */
    if (n == 0) {
        if (siz != 0)
            *d = '\0';      /* NUL-terminate dst */
        while (*s++)
            ;
    }

    return(s - src - 1);    /* count does not include NUL */
}

/*
 * Appends src to string dst of size siz (unlike strncat, siz is the
 * full size of dst, not space left).  At most siz-1 characters
 * will be copied.  Always NUL terminates (unless siz <= strlen(dst)).
 * Returns strlen(src) + MIN(siz, strlen(initial dst)).
 * If retval >= siz, truncation occurred.
 */
static inline size_t
_strlcat(char *dst, const char *src, size_t siz)
{
    char *d = dst;
    const char *s = src;
    size_t n = siz;
    size_t dlen;

    /* Find the end of dst and adjust bytes left but don't go past end */
    while (n-- != 0 && *d != '\0')
        d++;
    dlen = d - dst;
    n = siz - dlen;

    if (n == 0)
        return(dlen + strlen(s));
    while (*s != '\0') {
        if (n != 1) {
            *d++ = *s;
            n--;
        }
        s++;
    }
    *d = '\0';

    return(dlen + (s - src));   /* count does not include NUL */
}
#define strlcat _strlcat
#define strlcpy _strlcpy

//TIMEVALUE are the microseconds since 1/1/1970 represented as a int64_t.
//day and month are one based, year must be between 1970 & 2099.
//hours, minutes, seconds and microSecs are zero based.
//CALENDER_TIME is 'human based', i.e. year, month day are one based, times are zero based
//and each has its own periodicity and other crankiness.
//secs/day     = 86400 = 16.25 bits
//days/century = 36525 = 15.25 bits (no century correction required)
//secs/century =         31.50 bits
#define MILLISECS_PER_SEC   ((uint64_t)1000)
#define MICROSECS_PER_SEC   ((uint64_t)1000000)
#define TV2SECONDS(a)       ((UINT32)((a)/MICROSECS_PER_SEC))   //convert between TIMEVALUE and time_t
#define TV2MILLISECONDS(a)  ((UINT32)((a)/1000))                //convert TIMEVALUE to milliseconds
#define MILLISECONDS2TV(a)  ((int64_t)((a)*1000))               //convert milliSecs to TIMEVALUE
#define SECONDS2TV(a)       ((int64_t)((a)*MICROSECS_PER_SEC))  //convert seconds to TIMEVALUE
//JR, 11/03/03, this seems sort of weird...packet id shouldnt really be signed, should it?  perhaps we should leave this unsigned, and in the cases where an errorcode needs to be returned, we return that code separately...
#define PACKETID            INT32
#define SECS_PER_DAY        (60*60*24)
#define SECS_PER_HOUR       (60*60)
#define MICROSECS_PER_DAY   (((uint64_t)SECS_PER_DAY)*MICROSECS_PER_SEC)
#define MILLISECS_PER_DAY   (((uint64_t)SECS_PER_DAY)*1000)
#define DAYS_PER_FOUR_YEARS (4*365+1)

class cTIMEVALUE;
class cCALENDAR_TIME
   {public:
    UINT32 m_year, m_month, m_day, m_hour, m_minute, m_second, m_microSec;
    cCALENDAR_TIME         ();
    cGString   Format      (const char *fmtP=NULL);
    cTIMEVALUE GetTime     (char **);
    cTIMEVALUE GetDate     (char **);
    cTIMEVALUE GetDateTime (char **);
    void       Init        (void);
    bool       CalendarTime(const cTIMEVALUE*); //convert from timeValue to calendartime
    bool operator==        (const cCALENDAR_TIME &ct) const;
    bool operator!=        (const cCALENDAR_TIME &ct) const;
    private:
    void GetTriple         (char **ppP, UINT32 *aP, UINT32 *bP, UINT32 *cP, UINT32 *msecP);
   };

class cTIMEVALUE
   {static int64_t m_nSecondsSince1601;             // r/o after initial //units = 100 nSecs
    static   int   m_bias;                          // UTC = local + bias
    public:
    int64_t m_time;                                 //contains number of microseconds since 1/1/2000.
    cTIMEVALUE();
    cTIMEVALUE(int64_t t);
    bool       TimeValue   (const cCALENDAR_TIME *);//Convert from CalendarTime to timeValue
    cGString   Format      (const char *fmtP=NULL);
    cGString   FormatUTC   (const char *fmtP);
    cTIMEVALUE GetGmtvBase (void);
    cTIMEVALUE GetGmtv     (void);
   };

// these allow us to do sleep calls portable without depending on wxwidgets
#ifdef PICO_WIDGETS
    #define MilliSleep      wxMilliSleep
    #define ToWxString(str) wxString(str, wxConvLibc)
    #define WxToChar(wxstr) (wxstr).mb_str(wxConvLibc)
#elif defined(WIN32)
    #define MilliSleep(t)   WDC_Sleep(1000*(t), WDC_SLEEP_BUSY)
#elif defined(POSIX)
    #define MilliSleep(t)   usleep(1000*(t))
#else
    #error You need to define MilliSleep in always.h
#endif

 const uint64_t IEEE_ETHERNET_NUMBER_LO = 0x0050C2442000ULL;
 const uint64_t IEEE_ETHERNET_NUMBER_HI = 0x0050C2442FFFULL;
 const uint64_t E16_PART_NUMBER_LO      = 0x000E16004000ULL;
 const uint64_t E16_PART_NUMBER_HI      = 0x000E16004FFFULL;

#define XILINX_BITFILE_SIGNATURE          "\xFF\xFF\xFF\xFF\xAA\x99\x55\x66"
#define XILINX_BITFILE_SIGNATURE_REVERSED "\xFF\xFF\xFF\xFF\x55\x99\xAA\x66"

//array structure used by Wizards to manage replacements in wizards text files.
typedef struct {const char *fromP; char *toP; bool dealloc, isString;} REPLACE_TBL;

// the built-in XRCID only works for literals when in Unicode mode (due to a wxT on the arg)
#define XRCID_cstr(cstr) (wxXmlResource::GetXRCID(wxString((cstr), wxConvLibc)))

#endif // _ALWAYS_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
