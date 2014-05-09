#ifndef _WINNT_
#define _WINNT_

#if defined(_INC_TRACE_)
#warning  "winnt.h"
#endif
#ifdef __cplusplus
extern "C" {
#endif

#include <ctype.h>  
#include <basetsd.h>
// #define ANYSIZE_ARRAY 1       
// 
// #define UNALIGNED
// #define UNALIGNED64
// 
// #define MAX_NATURAL_ALIGNMENT sizeof(DWORD)
// #define MEMORY_ALLOCATION_ALIGNMENT 8
// #define DECLSPEC_IMPORT
// #define DECLSPEC_NORETURN
// #define DECLSPEC_ALIGN(x)
// #define SYSTEM_CACHE_ALIGNMENT_SIZE 64
// #define DECLSPEC_CACHEALIGN DECLSPEC_ALIGN(SYSTEM_CACHE_ALIGNMENT_SIZE)
// #define DECLSPEC_UUID(x)
// #define DECLSPEC_NOVTABLE
// #define DECLSPEC_SELECTANY
// #define NOP_FUNCTION (void)0
// #define DECLSPEC_ADDRSAFE
// #define DECLSPEC_NOINLINE
// // #define FORCEINLINE __inline
// #undef  DEPRECATE_SUPPORTED
// #define DECLSPEC_DEPRECATED_DDK
// #define PRAGMA_DEPRECATED_DDK 0
typedef void *PVOID;
// typedef void * POINTER_64 PVOID64;
// #define _cdecl
// #define NTAPI
// #define NTSYSCALLAPI DECLSPEC_ADDRSAFE
// //
// // Basics
// //
// 
#ifndef VOID
#define VOID void
typedef char CHAR;
typedef short SHORT;
typedef long LONG;
#endif
// 
// //
// // UNICODE (Wide Character) types
// //
// 
// #ifndef wchar_t
// #define wchar_t unsigned char
// #endif
#define __nullterminated
typedef wchar_t WCHAR;    // wc,   16-bit UNICODE character
// typedef WCHAR *PWCHAR, *LPWCH, *PWCH;
// typedef CONST WCHAR *LPCWCH, *PCWCH;
typedef __nullterminated WCHAR *NWPSTR, *LPWSTR, *PWSTR;
// typedef __nullterminated PWSTR *PZPWSTR;
// typedef __nullterminated CONST PWSTR *PCZPWSTR;
// typedef __nullterminated WCHAR UNALIGNED *LPUWSTR, *PUWSTR;
typedef __nullterminated CONST WCHAR *LPCWSTR, *PCWSTR;
// typedef __nullterminated PCWSTR *PZPCWSTR;
// typedef __nullterminated CONST WCHAR UNALIGNED *LPCUWSTR, *PCUWSTR;
// 
// //
// // ANSI (Multi-byte Character) types
// //
// typedef CHAR *PCHAR, *LPCH, *PCH;
// typedef CONST CHAR *LPCCH, *PCCH;
// 
typedef __nullterminated CHAR *NPSTR, *LPSTR, *PSTR;
// typedef __nullterminated PSTR *PZPSTR;
// typedef __nullterminated CONST PSTR *PCZPSTR;
typedef __nullterminated CONST CHAR *LPCSTR, *PCSTR;
// typedef __nullterminated PCSTR *PZPCSTR;
// 
// //
// // Neutral ANSI/UNICODE types and macros
// //
#ifdef  UNICODE                     // r_winnt
// 
#ifndef _TCHAR_DEFINED
typedef WCHAR TCHAR, *PTCHAR;
// typedef WCHAR TBYTE , *PTBYTE ;
// #define _TCHAR_DEFINED
#endif /* !_TCHAR_DEFINED */
// 
// typedef LPWSTR LPTCH, PTCH;
typedef LPWSTR PTSTR, LPTSTR;
typedef LPCWSTR PCTSTR, LPCTSTR;
// typedef LPUWSTR PUTSTR, LPUTSTR;
// typedef LPCUWSTR PCUTSTR, LPCUTSTR;
// typedef LPWSTR LP;
// #define __TEXT(quote) L##quote      // r_winnt
// 
#else   /* UNICODE */               // r_winnt
// 
#ifndef _TCHAR_DEFINED
typedef char TCHAR, *PTCHAR;
// typedef unsigned char TBYTE , *PTBYTE ;
// #define _TCHAR_DEFINED
#endif /* !_TCHAR_DEFINED */
// 
// typedef LPSTR LPTCH, PTCH;
typedef LPSTR PTSTR, LPTSTR, PUTSTR, LPUTSTR;
typedef LPCSTR PCTSTR, LPCTSTR, PCUTSTR, LPCUTSTR;
// #define __TEXT(quote) quote         // r_winnt
// 
#endif /* UNICODE */                // r_winnt
// #define TEXT(quote) __TEXT(quote)   // r_winnt
// 
// 
// typedef SHORT *PSHORT;  
// typedef LONG *PLONG;    
typedef PVOID HANDLE;
// #define DECLARE_HANDLE(name) typedef HANDLE name
// typedef HANDLE *PHANDLE;
// //
// // Flag (bit) fields
// //
// 
// typedef BYTE   FCHAR;
// typedef WORD   FSHORT;
// typedef DWORD  FLONG;
// 
// // Component Object Model defines, and macros
// 
// #ifndef _HRESULT_DEFINED
// #define _HRESULT_DEFINED
// typedef LONG HRESULT;
// 
// #endif // !_HRESULT_DEFINED
// 
// #ifdef __cplusplus
//     #define EXTERN_C    extern "C"
// #else
//     #define EXTERN_C    extern
// #endif
// 
// #define STDMETHODCALLTYPE       __stdcall
// typedef char CCHAR;          
// typedef DWORD LCID;         
// typedef PDWORD PLCID;       
// typedef WORD   LANGID;      
// #define APPLICATION_ERROR_MASK       0x20000000
// #define ERROR_SEVERITY_SUCCESS       0x00000000
// #define ERROR_SEVERITY_INFORMATIONAL 0x40000000
// #define ERROR_SEVERITY_WARNING       0x80000000
// #define ERROR_SEVERITY_ERROR         0xC0000000
// typedef LONGLONG *PLONGLONG;
// typedef ULONGLONG *PULONGLONG;
// 
// // Update Sequence Number
// 
// typedef LONGLONG USN;
// #define ANSI_NULL ((CHAR)0)     
// #define UNICODE_NULL ((WCHAR)0) 
// #define UNICODE_STRING_MAX_BYTES ((WORD  ) 65534) 
// #define UNICODE_STRING_MAX_CHARS (32767) 
// typedef BYTE  BOOLEAN;           
// typedef BOOLEAN *PBOOLEAN;       
// #define MINCHAR     0x80        
// #define MAXCHAR     0x7f        
// #define MINSHORT    0x8000      
// #define MAXSHORT    0x7fff      
// #define MINLONG     0x80000000  
// #define MAXLONG     0x7fffffff  
// #define MAXBYTE     0xff        
// #define MAXWORD     0xffff      
// #define MAXDWORD    0xffffffff  
// //
// // Calculate the byte offset of a field in a structure of type type.
// //
// 
// #define FIELD_OFFSET(type, field)    ((LONG)(LONG_PTR)&(((type *)0)->field))
// 
// #define VER_SERVER_NT                       0x80000000
// #define VER_WORKSTATION_NT                  0x40000000
// #define VER_SUITE_SMALLBUSINESS             0x00000001
// #define VER_SUITE_ENTERPRISE                0x00000002
// #define VER_SUITE_BACKOFFICE                0x00000004
// #define VER_SUITE_COMMUNICATIONS            0x00000008
// #define VER_SUITE_TERMINAL                  0x00000010
// #define VER_SUITE_SMALLBUSINESS_RESTRICTED  0x00000020
// #define VER_SUITE_EMBEDDEDNT                0x00000040
// #define VER_SUITE_DATACENTER                0x00000080
// #define VER_SUITE_SINGLEUSERTS              0x00000100
// #define VER_SUITE_PERSONAL                  0x00000200
// #define VER_SUITE_BLADE                     0x00000400
// #define VER_SUITE_EMBEDDED_RESTRICTED       0x00000800
// #define VER_SUITE_SECURITY_APPLIANCE        0x00001000
// #define VER_SUITE_STORAGE_SERVER            0x00002000
// #define VER_SUITE_COMPUTE_SERVER            0x00004000
// 
#define SYNCHRONIZE                      (0x00100000L)
#define STANDARD_RIGHTS_READ             (READ_CONTROL)
#define STANDARD_RIGHTS_WRITE            (READ_CONTROL)
#define FILE_READ_DATA            ( 0x0001 )    // file & pipe
// #define FILE_LIST_DIRECTORY       ( 0x0001 )    // directory
// 
#define FILE_WRITE_DATA           ( 0x0002 )    // file & pipe
// #define FILE_ADD_FILE             ( 0x0002 )    // directory
// 
// #define FILE_APPEND_DATA          ( 0x0004 )    // file
// #define FILE_ADD_SUBDIRECTORY     ( 0x0004 )    // directory
// #define FILE_CREATE_PIPE_INSTANCE ( 0x0004 )    // named pipe
// 
// 
#define FILE_READ_EA              ( 0x0008 )    // file & directory
// 
#define FILE_WRITE_EA             ( 0x0010 )    // file & directory
// 
// #define FILE_EXECUTE              ( 0x0020 )    // file
// #define FILE_TRAVERSE             ( 0x0020 )    // directory
// 
// #define FILE_DELETE_CHILD         ( 0x0040 )    // directory
// 
#define FILE_READ_ATTRIBUTES      ( 0x0080 )    // all
// 
#define FILE_WRITE_ATTRIBUTES     ( 0x0100 )    // all
// 
// #define FILE_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE | 0x1FF)
// 
 #define FILE_GENERIC_READ         (STANDARD_RIGHTS_READ     |\
                                    FILE_READ_DATA           |\
                                    FILE_READ_ATTRIBUTES     |\
                                    FILE_READ_EA             |\
                                    SYNCHRONIZE)
 
 
 #define FILE_GENERIC_WRITE        (STANDARD_RIGHTS_WRITE    |\
                                    FILE_WRITE_DATA          |\
                                    FILE_WRITE_ATTRIBUTES    |\
                                    FILE_WRITE_EA            |\
                                    FILE_APPEND_DATA         |\
                                    SYNCHRONIZE)
// 
// 
// #define FILE_GENERIC_EXECUTE      (STANDARD_RIGHTS_EXECUTE  |\
//                                    FILE_READ_ATTRIBUTES     |\
//                                    FILE_EXECUTE             |\
//                                    SYNCHRONIZE)
// 
#define FILE_SHARE_READ                 0x00000001  
#define FILE_SHARE_WRITE                0x00000002  
// #define FILE_SHARE_DELETE               0x00000004  
// #define FILE_ATTRIBUTE_READONLY             0x00000001  
// #define FILE_ATTRIBUTE_HIDDEN               0x00000002  
// #define FILE_ATTRIBUTE_SYSTEM               0x00000004  
#define FILE_ATTRIBUTE_DIRECTORY            0x00000010  
// #define FILE_ATTRIBUTE_ARCHIVE              0x00000020  
// #define FILE_ATTRIBUTE_DEVICE               0x00000040  
// #define FILE_ATTRIBUTE_NORMAL               0x00000080  
// #define FILE_ATTRIBUTE_TEMPORARY            0x00000100  
// #define FILE_ATTRIBUTE_SPARSE_FILE          0x00000200  
// #define FILE_ATTRIBUTE_REPARSE_POINT        0x00000400  
// #define FILE_ATTRIBUTE_COMPRESSED           0x00000800  
// #define FILE_ATTRIBUTE_OFFLINE              0x00001000  
// #define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  0x00002000  
// #define FILE_ATTRIBUTE_ENCRYPTED            0x00004000  
// #define FILE_NOTIFY_CHANGE_FILE_NAME    0x00000001   
// #define FILE_NOTIFY_CHANGE_DIR_NAME     0x00000002   
// #define FILE_NOTIFY_CHANGE_ATTRIBUTES   0x00000004   
// #define FILE_NOTIFY_CHANGE_SIZE         0x00000008   
// #define FILE_NOTIFY_CHANGE_LAST_WRITE   0x00000010   
// #define FILE_NOTIFY_CHANGE_LAST_ACCESS  0x00000020   
// #define FILE_NOTIFY_CHANGE_CREATION     0x00000040   
// #define FILE_NOTIFY_CHANGE_SECURITY     0x00000100   
// #define FILE_ACTION_ADDED                   0x00000001   
// #define FILE_ACTION_REMOVED                 0x00000002   
// #define FILE_ACTION_MODIFIED                0x00000003   
// #define FILE_ACTION_RENAMED_OLD_NAME        0x00000004   
// #define FILE_ACTION_RENAMED_NEW_NAME        0x00000005   
// #define MAILSLOT_NO_MESSAGE             ((DWORD)-1) 
// #define MAILSLOT_WAIT_FOREVER           ((DWORD)-1) 
// #define FILE_CASE_SENSITIVE_SEARCH      0x00000001  
// #define FILE_CASE_PRESERVED_NAMES       0x00000002  
// #define FILE_UNICODE_ON_DISK            0x00000004  
// #define FILE_PERSISTENT_ACLS            0x00000008  
// #define FILE_FILE_COMPRESSION           0x00000010  
// #define FILE_VOLUME_QUOTAS              0x00000020  
// #define FILE_SUPPORTS_SPARSE_FILES      0x00000040  
// #define FILE_SUPPORTS_REPARSE_POINTS    0x00000080  
// #define FILE_SUPPORTS_REMOTE_STORAGE    0x00000100  
// #define FILE_VOLUME_IS_COMPRESSED       0x00008000  
// #define FILE_SUPPORTS_OBJECT_IDS        0x00010000  
// #define FILE_SUPPORTS_ENCRYPTION        0x00020000  
// #define FILE_NAMED_STREAMS              0x00040000  
// #define FILE_READ_ONLY_VOLUME           0x00080000  
 
typedef int64_t LONGLONG;
#define MAXLONGLONG                      (0x7fffffffffffffff)

typedef union _LARGE_INTEGER {
    struct {
        DWORD LowPart;
        LONG HighPart;
    };
    struct {
        DWORD LowPart;
        LONG HighPart;
    } u;
    LONGLONG QuadPart;
} LARGE_INTEGER;

//
//  These are the generic rights.
//

#define GENERIC_READ                     (0x80000000L)
#define GENERIC_WRITE                    (0x40000000L)

#ifdef __cplusplus
}
#endif

#endif /* _WINNT_ */
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
