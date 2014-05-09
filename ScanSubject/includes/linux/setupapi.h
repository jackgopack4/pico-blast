#ifndef _INC_SETUPAPI
#define _INC_SETUPAPI

//
// Define API decoration for direct importing of DLL references.
//
#if !defined(_SETUPAPI_)
#define WINSETUPAPI DECLSPEC_IMPORT
#else
#define WINSETUPAPI
#endif

#ifdef __cplusplus
extern "C" {
#endif

//
// Define type for reference to device information set
//
typedef PVOID HDEVINFO;

//
// Device information structure (references a device instance
// that is a member of a device information set)
//
typedef struct _SP_DEVINFO_DATA {
    DWORD cbSize;
    GUID  ClassGuid;
    DWORD DevInst;    // DEVINST handle
    ULONG_PTR Reserved;
} SP_DEVINFO_DATA, *PSP_DEVINFO_DATA;

#ifdef __cplusplus
}
#endif

// #include <poppack.h>

#endif // _INC_SETUPAPI
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
