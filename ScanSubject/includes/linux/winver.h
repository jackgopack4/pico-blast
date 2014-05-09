#ifndef VER_H
#define VER_H

#ifdef __cplusplus
extern "C" {
#endif

/* Returns size of version info in bytes */
DWORD
APIENTRY
GetFileVersionInfoSizeA(
    LPCSTR lptstrFilename, /* Filename of version stamped file */
    LPDWORD lpdwHandle
    );                      /* Information for use by GetFileVersionInfo */
/* Returns size of version info in bytes */
DWORD
APIENTRY
GetFileVersionInfoSizeW(
    LPCWSTR lptstrFilename, /* Filename of version stamped file */
    LPDWORD lpdwHandle
    );                      /* Information for use by GetFileVersionInfo */
#ifdef UNICODE
#define GetFileVersionInfoSize  GetFileVersionInfoSizeW
#else
#define GetFileVersionInfoSize  GetFileVersionInfoSizeA
#endif // !UNICODE

/* Read version info into buffer */
BOOL
APIENTRY
GetFileVersionInfoA(
    LPCSTR lptstrFilename, /* Filename of version stamped file */
    DWORD dwHandle,         /* Information from GetFileVersionSize */
    DWORD dwLen,            /* Length of buffer for info */
    LPVOID lpData
    );                      /* Buffer to place the data structure */
/* Read version info into buffer */
BOOL
APIENTRY
GetFileVersionInfoW(
    LPCWSTR lptstrFilename, /* Filename of version stamped file */
    DWORD dwHandle,         /* Information from GetFileVersionSize */
    DWORD dwLen,            /* Length of buffer for info */
    LPVOID lpData
    );                      /* Buffer to place the data structure */
#ifdef UNICODE
#define GetFileVersionInfo  GetFileVersionInfoW
#else
#define GetFileVersionInfo  GetFileVersionInfoA
#endif // !UNICODE

BOOL
APIENTRY
VerQueryValueA(
        const LPVOID pBlock,
        LPSTR lpSubBlock,
        LPVOID * lplpBuffer,
        PUINT puLen
        );
BOOL
APIENTRY
VerQueryValueW(
        const LPVOID pBlock,
        LPWSTR lpSubBlock,
        LPVOID * lplpBuffer,
        PUINT puLen
        );
#ifdef UNICODE
#define VerQueryValue  VerQueryValueW
#else
#define VerQueryValue  VerQueryValueA
#endif // !UNICODE


#ifdef __cplusplus
}
#endif

#endif  /* !VER_H */
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
