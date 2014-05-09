#ifndef _WINDOWS_
#define _WINDOWS_

#include "linux.h"

#if defined(_INC_TRACE_)
#warning "windows.h"
#endif

#ifndef WINVER
#define WINVER 0x0501
#else
#if defined(_WIN32_WINNT) && (WINVER < 0x0400) && (_WIN32_WINNT > 0x0400)
#error WINVER setting conflicts with _WIN32_WINNT setting
#endif
#endif

#ifndef _INC_WINDOWS
#define _INC_WINDOWS

#if defined (_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#if !defined(_68K_) && !defined(_MPPC_) && !defined(_X86_) && !defined(_IA64_) && !defined(_AMD64_) && defined(_M_IX86)
#define _X86_
#endif

#if !defined(_68K_) && !defined(_MPPC_) && !defined(_X86_) && !defined(_IA64_) && !defined(_AMD64_) && defined(_M_AMD64)
#define _AMD64_
#endif

#if !defined(_68K_) && !defined(_MPPC_) && !defined(_X86_) && !defined(_IA64_) && !defined(_AMD64_) && defined(_M_M68K)
#define _68K_
#endif

#if !defined(_68K_) && !defined(_MPPC_) && !defined(_X86_) && !defined(_IA64_) && !defined(_AMD64_) && defined(_M_MPPC)
#define _MPPC_
#endif

#if !defined(_68K_) && !defined(_MPPC_) && !defined(_X86_) && !defined(_M_IX86) && !defined(_AMD64_) && defined(_M_IA64)
#if !defined(_IA64_)
#define _IA64_
#endif // !_IA64_
#endif

#include <excpt.h>
#include <stdarg.h>
#include <windef.h>
#include <rpcndr.h>
#include <winbase.h>
#include <wingdi.h>
#include <winuser.h>
#include <wincon.h>
#include <winver.h>
#include <winreg.h>
#include <winnetwk.h>
#include <stralign.h>
#include <mmsystem.h>
#include <winioctl.h>

#endif /* _INC_WINDOWS */
#endif /* _WINDOWS_ */
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
