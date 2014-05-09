
#ifndef _WINBASE_
#define _WINBASE_
//
// Define API decoration for direct importing of DLL references.
//
#define WINADVAPI
#define WINBASEAPI

#ifdef __cplusplus
extern "C" {
#endif

#include <winerror.h>

#define INVALID_HANDLE_VALUE ((HANDLE)(LONG_PTR)-1)


typedef struct _OVERLAPPED {
    ULONG_PTR Internal;
    ULONG_PTR InternalHigh;
    union {
        struct {
            DWORD Offset;
            DWORD OffsetHigh;
        };

        PVOID Pointer;
    };

    HANDLE  hEvent;
} OVERLAPPED, *LPOVERLAPPED;


// #define INVALID_FILE_SIZE ((DWORD)0xFFFFFFFF)
// #define INVALID_SET_FILE_POINTER ((DWORD)-1)
// #define INVALID_FILE_ATTRIBUTES ((DWORD)-1)
// 
// #define FILE_BEGIN           0
// #define FILE_CURRENT         1
// #define FILE_END             2
// 
// #define TIME_ZONE_ID_INVALID ((DWORD)0xFFFFFFFF)
// 
// #define WAIT_FAILED ((DWORD)0xFFFFFFFF)
// #define WAIT_OBJECT_0       ((STATUS_WAIT_0 ) + 0 )
// 
// #define WAIT_ABANDONED         ((STATUS_ABANDONED_WAIT_0 ) + 0 )
// #define WAIT_ABANDONED_0       ((STATUS_ABANDONED_WAIT_0 ) + 0 )
// 
// #define WAIT_IO_COMPLETION                  STATUS_USER_APC
// #define STILL_ACTIVE                        STATUS_PENDING
// #define EXCEPTION_ACCESS_VIOLATION          STATUS_ACCESS_VIOLATION
// #define EXCEPTION_DATATYPE_MISALIGNMENT     STATUS_DATATYPE_MISALIGNMENT
// #define EXCEPTION_BREAKPOINT                STATUS_BREAKPOINT
// #define EXCEPTION_SINGLE_STEP               STATUS_SINGLE_STEP
// #define EXCEPTION_ARRAY_BOUNDS_EXCEEDED     STATUS_ARRAY_BOUNDS_EXCEEDED
// #define EXCEPTION_FLT_DENORMAL_OPERAND      STATUS_FLOAT_DENORMAL_OPERAND
// #define EXCEPTION_FLT_DIVIDE_BY_ZERO        STATUS_FLOAT_DIVIDE_BY_ZERO
// #define EXCEPTION_FLT_INEXACT_RESULT        STATUS_FLOAT_INEXACT_RESULT
// #define EXCEPTION_FLT_INVALID_OPERATION     STATUS_FLOAT_INVALID_OPERATION
// #define EXCEPTION_FLT_OVERFLOW              STATUS_FLOAT_OVERFLOW
// #define EXCEPTION_FLT_STACK_CHECK           STATUS_FLOAT_STACK_CHECK
// #define EXCEPTION_FLT_UNDERFLOW             STATUS_FLOAT_UNDERFLOW
// #define EXCEPTION_INT_DIVIDE_BY_ZERO        STATUS_INTEGER_DIVIDE_BY_ZERO
// #define EXCEPTION_INT_OVERFLOW              STATUS_INTEGER_OVERFLOW
// #define EXCEPTION_PRIV_INSTRUCTION          STATUS_PRIVILEGED_INSTRUCTION
// #define EXCEPTION_IN_PAGE_ERROR             STATUS_IN_PAGE_ERROR
// #define EXCEPTION_ILLEGAL_INSTRUCTION       STATUS_ILLEGAL_INSTRUCTION
// #define EXCEPTION_NONCONTINUABLE_EXCEPTION  STATUS_NONCONTINUABLE_EXCEPTION
// #define EXCEPTION_STACK_OVERFLOW            STATUS_STACK_OVERFLOW
// #define EXCEPTION_INVALID_DISPOSITION       STATUS_INVALID_DISPOSITION
// #define EXCEPTION_GUARD_PAGE                STATUS_GUARD_PAGE_VIOLATION
// #define EXCEPTION_INVALID_HANDLE            STATUS_INVALID_HANDLE
// #define EXCEPTION_POSSIBLE_DEADLOCK         STATUS_POSSIBLE_DEADLOCK
// #define CONTROL_C_EXIT                      STATUS_CONTROL_C_EXIT
// //
// // File creation flags must start at the high end since they
// // are combined with the attributes
// //
// 
// #define FILE_FLAG_WRITE_THROUGH         0x80000000
// #define FILE_FLAG_OVERLAPPED            0x40000000
#define FILE_FLAG_NO_BUFFERING          0x20000000
// #define FILE_FLAG_RANDOM_ACCESS         0x10000000
// #define FILE_FLAG_SEQUENTIAL_SCAN       0x08000000
// #define FILE_FLAG_DELETE_ON_CLOSE       0x04000000
// #define FILE_FLAG_BACKUP_SEMANTICS      0x02000000
// #define FILE_FLAG_POSIX_SEMANTICS       0x01000000
// #define FILE_FLAG_OPEN_REPARSE_POINT    0x00200000
// #define FILE_FLAG_OPEN_NO_RECALL        0x00100000
// #define FILE_FLAG_FIRST_PIPE_INSTANCE   0x00080000
// 
// #define CREATE_NEW          1
// #define CREATE_ALWAYS       2
#define OPEN_EXISTING       3
// #define OPEN_ALWAYS         4
// #define TRUNCATE_EXISTING   5
// 
// //
// // Define the Security Quality of Service bits to be passed
// // into CreateFile
// //
// 
// #define SECURITY_ANONYMOUS          ( SecurityAnonymous      << 16 )
// #define SECURITY_IDENTIFICATION     ( SecurityIdentification << 16 )
// #define SECURITY_IMPERSONATION      ( SecurityImpersonation  << 16 )
// #define SECURITY_DELEGATION         ( SecurityDelegation     << 16 )
// 
// #define SECURITY_CONTEXT_TRACKING  0x00040000
// #define SECURITY_EFFECTIVE_ONLY    0x00080000
// 
// #define SECURITY_SQOS_PRESENT      0x00100000
// #define SECURITY_VALID_SQOS_FLAGS  0x001F0000

//
// dwCreationFlag values
//
#define CREATE_SUSPENDED                  0x00000004

 
typedef DWORD (WINAPI *PTHREAD_START_ROUTINE)(
    LPVOID lpThreadParameter
    );
typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;

typedef struct _SECURITY_ATTRIBUTES {
    DWORD nLength;
    LPVOID lpSecurityDescriptor;
    BOOL bInheritHandle;
} SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

typedef struct _PROCESS_INFORMATION {
    HANDLE hProcess;
    HANDLE hThread;
    DWORD dwProcessId;
    DWORD dwThreadId;
} PROCESS_INFORMATION, *PPROCESS_INFORMATION, *LPPROCESS_INFORMATION;

typedef struct _WIN32_FIND_DATAA {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
#define EM_INVALID		0x10
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    CHAR   cFileName[ MAX_PATH ];
    CHAR   cAlternateFileName[ 14 ];
#ifdef _MAC
    DWORD dwFileType;
    DWORD dwCreatorType;
    WORD  wFinderFlags;
#endif
} WIN32_FIND_DATAA, *PWIN32_FIND_DATAA, *LPWIN32_FIND_DATAA;

typedef struct _WIN32_FIND_DATAW {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    WCHAR  cFileName[ MAX_PATH ];
    WCHAR  cAlternateFileName[ 14 ];
#ifdef _MAC
    DWORD dwFileType;

    DWORD dwCreatorType;
    WORD  wFinderFlags;
#endif
} WIN32_FIND_DATAW, *PWIN32_FIND_DATAW, *LPWIN32_FIND_DATAW;

#ifdef UNICODE
typedef WIN32_FIND_DATAW WIN32_FIND_DATA;
typedef PWIN32_FIND_DATAW PWIN32_FIND_DATA;
typedef LPWIN32_FIND_DATAW LPWIN32_FIND_DATA;
#else
typedef WIN32_FIND_DATAA WIN32_FIND_DATA;
typedef PWIN32_FIND_DATAA PWIN32_FIND_DATA;
typedef LPWIN32_FIND_DATAA LPWIN32_FIND_DATA;
#endif // UNICODE

WINBASEAPI
HANDLE
WINAPI
FindFirstFileA(
    LPCSTR lpFileName,
    LPWIN32_FIND_DATAA lpFindFileData
    );
WINBASEAPI
HANDLE
WINAPI
FindFirstFileW(
    LPCWSTR lpFileName,
    LPWIN32_FIND_DATAW lpFindFileData
    );
#ifdef UNICODE
#define FindFirstFile  FindFirstFileW
#else
#define FindFirstFile  FindFirstFileA
#endif // !UNICODE

WINBASEAPI
BOOL
WINAPI
FindNextFileA(
    HANDLE hFindFile,
    LPWIN32_FIND_DATAA lpFindFileData
    );
WINBASEAPI
BOOL
WINAPI
FindNextFileW(
    HANDLE hFindFile,
    LPWIN32_FIND_DATAW lpFindFileData
    );
#ifdef UNICODE
#define FindNextFile  FindNextFileW
#else
#define FindNextFile  FindNextFileA
#endif // !UNICODE

WINBASEAPI
BOOL
WINAPI
FindClose(
    HANDLE hFindFile
    );

WINBASEAPI
LPSTR
WINAPI
GetCommandLineA(
    VOID
    );

WINBASEAPI
LPWSTR
WINAPI
GetCommandLineW(
    VOID
    );
#ifdef UNICODE
#define GetCommandLine  GetCommandLineW
#else
#define GetCommandLine  GetCommandLineA
#endif // !UNICODE

#define FORMAT_MESSAGE_ALLOCATE_BUFFER 0x00000100
#define FORMAT_MESSAGE_IGNORE_INSERTS  0x00000200
#define FORMAT_MESSAGE_FROM_STRING     0x00000400
#define FORMAT_MESSAGE_FROM_HMODULE    0x00000800
#define FORMAT_MESSAGE_FROM_SYSTEM     0x00001000
#define FORMAT_MESSAGE_ARGUMENT_ARRAY  0x00002000
#define FORMAT_MESSAGE_MAX_WIDTH_MASK  0x000000FF

WINBASEAPI
DWORD
WINAPI
FormatMessageA(
    DWORD dwFlags,
    LPCVOID lpSource,
    DWORD dwMessageId,
    DWORD dwLanguageId,
    LPSTR lpBuffer,
    DWORD nSize,
    va_list *Arguments
    );

WINBASEAPI
DWORD
WINAPI
FormatMessageW(
    DWORD dwFlags,
    LPCVOID lpSource,
    DWORD dwMessageId,
    DWORD dwLanguageId,
    LPWSTR lpBuffer,
    DWORD nSize,
    va_list *Arguments
    );
#if defined(UNICODE) && 0
#define FormatMessage  FormatMessageW
// #warning "UNICODE"
#else
#define FormatMessage  FormatMessageA
#endif // !UNICODE

#ifndef _FILETIME_
#define _FILETIME_
typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
} FILETIME, *PFILETIME, *LPFILETIME;
#endif
#ifdef __cplusplus
}
#endif

typedef struct _STARTUPINFOA {
    DWORD   cb;
    LPSTR   lpReserved;
    LPSTR   lpDesktop;
    LPSTR   lpTitle;
    DWORD   dwX;
    DWORD   dwY;
    DWORD   dwXSize;
    DWORD   dwYSize;
    DWORD   dwXCountChars;
    DWORD   dwYCountChars;
    DWORD   dwFillAttribute;
    DWORD   dwFlags;
    WORD    wShowWindow;
    WORD    cbReserved2;
    LPBYTE  lpReserved2;
    HANDLE  hStdInput;
    HANDLE  hStdOutput;
    HANDLE  hStdError;
} STARTUPINFOA, *LPSTARTUPINFOA;
typedef struct _STARTUPINFOW {
    DWORD   cb;
    LPWSTR  lpReserved;
    LPWSTR  lpDesktop;
    LPWSTR  lpTitle;
    DWORD   dwX;
    DWORD   dwY;
    DWORD   dwXSize;
    DWORD   dwYSize;
    DWORD   dwXCountChars;
    DWORD   dwYCountChars;
    DWORD   dwFillAttribute;
    DWORD   dwFlags;
    WORD    wShowWindow;
    WORD    cbReserved2;
    LPBYTE  lpReserved2;
    HANDLE  hStdInput;
    HANDLE  hStdOutput;
    HANDLE  hStdError;
} STARTUPINFOW, *LPSTARTUPINFOW;
#ifdef UNICODE
typedef STARTUPINFOW STARTUPINFO;
typedef LPSTARTUPINFOW LPSTARTUPINFO;
#else
typedef STARTUPINFOA STARTUPINFO;
typedef LPSTARTUPINFOA LPSTARTUPINFO;
#endif // UNICODE
//
// Performance counter API's
//
WINAPI BOOL		QueryPerformanceCounter(LARGE_INTEGER *count);
WINAPI BOOL     QueryPerformanceFrequency(LARGE_INTEGER *lpFrequency);

WINBASEAPI
BOOL
WINAPI
CreateProcessA(
     LPCSTR lpApplicationName,
     LPSTR lpCommandLine,
     LPSECURITY_ATTRIBUTES lpProcessAttributes,
     LPSECURITY_ATTRIBUTES lpThreadAttributes,
     BOOL bInheritHandles,
     DWORD dwCreationFlags,
     LPVOID lpEnvironment,
     LPCSTR lpCurrentDirectory,
     LPSTARTUPINFOA lpStartupInfo,
     LPPROCESS_INFORMATION lpProcessInformation
    );

WINBASEAPI
BOOL
WINAPI
CreateProcessW(
     LPCWSTR lpApplicationName,
     LPWSTR lpCommandLine,
     LPSECURITY_ATTRIBUTES lpProcessAttributes,
     LPSECURITY_ATTRIBUTES lpThreadAttributes,
     BOOL bInheritHandles,
     DWORD dwCreationFlags,
     LPVOID lpEnvironment,
     LPCWSTR lpCurrentDirectory,
     LPSTARTUPINFOW lpStartupInfo,
     LPPROCESS_INFORMATION lpProcessInformation
    );
#ifdef UNICODE
#define CreateProcess  CreateProcessW
#else
#define CreateProcess  CreateProcessA
#endif // !UNICODE

typedef DWORD (WINAPI *PTHREAD_START_ROUTINE)(
    LPVOID lpThreadParameter
    );
typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;

WINBASEAPI
HANDLE
WINAPI
CreateThread(
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    SIZE_T dwStackSize,
    LPTHREAD_START_ROUTINE lpStartAddress,
    LPVOID lpParameter,
    DWORD dwCreationFlags,
    LPDWORD lpThreadId
    );

WINBASEAPI
BOOL
WINAPI
DeviceIoControl(
    HANDLE hDevice,
    DWORD dwIoControlCode, 
    LPVOID lpInBuffer,
    DWORD nInBufferSize,
    LPVOID lpOutBuffer,
    DWORD nOutBufferSize,
    LPDWORD lpBytesReturned,
    LPOVERLAPPED lpOverlapped
    );

WINBASEAPI
HMODULE
WINAPI
GetModuleHandleA(
    LPCSTR lpModuleName
    );
WINBASEAPI
HMODULE
WINAPI
GetModuleHandleW(
    LPCWSTR lpModuleName
    );
#ifdef UNICODE
#define GetModuleHandle  GetModuleHandleW
#else
#define GetModuleHandle  GetModuleHandleA
#endif // !UNICODE

WINBASEAPI
DWORD
WINAPI
GetFileAttributesA(
    LPCSTR lpFileName
    );
WINBASEAPI
DWORD
WINAPI
GetFileAttributesW(
    LPCWSTR lpFileName
    );
#ifdef UNICODE
#define GetFileAttributes  GetFileAttributesW
#else
#define GetFileAttributes  GetFileAttributesA
#endif // !UNICODE

// dll stuff
// HMODULE LoadLibrary(const char * name);
#define FreeLibrary(libhandle) dlclose(libhandle)

WINBASEAPI HMODULE WINAPI LoadLibraryA(LPCSTR lpLibFileName);
WINBASEAPI HMODULE WINAPI LoadLibraryW(LPCWSTR lpLibFileName);
#ifdef UNICODE
#define LoadLibrary  LoadLibraryW
#else
#define LoadLibrary  LoadLibraryA
#endif // !UNICODE

WINBASEAPI
HANDLE
WINAPI
CreateFileA(
    LPCSTR lpFileName,
    DWORD dwDesiredAccess,
    DWORD dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD dwCreationDisposition,
    DWORD dwFlagsAndAttributes,
    HANDLE hTemplateFile
    );
WINBASEAPI
HANDLE
WINAPI
CreateFileW(
    LPCWSTR lpFileName,
    DWORD dwDesiredAccess,
    DWORD dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD dwCreationDisposition,
    DWORD dwFlagsAndAttributes,
    HANDLE hTemplateFile
    );
#ifdef UNICODE
#define CreateFile  CreateFileW
#else
#define CreateFile  CreateFileA
#endif // !UNICODE

WINBASEAPI
BOOL
WINAPI
CloseHandle(
    HANDLE hObject
    );

WINBASEAPI
DWORD
WINAPI
GetLastError(
    VOID
    );

WINBASEAPI
VOID
WINAPI
SetLastError(
    DWORD dwErrCode
    );


WINBASEAPI
BOOL
WINAPI
WriteFile(
    HANDLE hFile,
    LPCVOID lpBuffer,
    DWORD nNumberOfBytesToWrite,
    LPDWORD lpNumberOfBytesWritten,
    LPOVERLAPPED lpOverlapped
    );

WINBASEAPI
BOOL
WINAPI
ReadFile(
    HANDLE hFile,
    LPVOID lpBuffer,
    DWORD nNumberOfBytesToRead,
    LPDWORD lpNumberOfBytesRead,
    LPOVERLAPPED lpOverlapped
    );

WINBASEAPI
HANDLE
WINAPI
CreateMutexA(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
    BOOL bInitialOwner,
    LPCSTR lpName
    );

WINBASEAPI
HANDLE
WINAPI
CreateMutexW(
    LPSECURITY_ATTRIBUTES lpMutexAttributes,
    BOOL bInitialOwner,
    LPCWSTR lpName
    );
#ifdef UNICODE
#define CreateMutex  CreateMutexW
#else
#define CreateMutex  CreateMutexA
#endif // !UNICODE

WINBASEAPI
BOOL
WINAPI
ReleaseMutex(
    HANDLE hMutex
    );

#define INFINITE            0xFFFFFFFF  // Infinite timeout

WINBASEAPI
DWORD
WINAPI
WaitForSingleObject(
    HANDLE hHandle,
    DWORD dwMilliseconds
    );

#endif // _WINBASE_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
