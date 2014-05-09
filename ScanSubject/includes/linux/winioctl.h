
#ifndef _WINIOCTL_
#define _WINIOCTL_

#define METHOD_BUFFERED                 0
#define FILE_READ_ACCESS          ( 0x0001 )    // file & pipe
#define FILE_WRITE_ACCESS         ( 0x0002 )    // file & pipe


#define CTL_CODE( DeviceType, Function, Method, Access ) (                 \
    ((DeviceType) << 16) | ((Access) << 14) | ((Function) << 2) | (Method) \
)
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif // _WINIOCTL_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
