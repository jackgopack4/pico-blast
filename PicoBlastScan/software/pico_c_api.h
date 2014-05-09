/* pico_c_api.h: C API bindings to the C++ pico library (libpico)
*
* If you want to write C code and link against libpico, look no further.
*/
#ifndef _PICO_C_API_H_
#define _PICO_C_API_H_
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#else
typedef struct {} PicoDrv; /* Opaque handle that C++ will resolve */
#endif
   
int FindPico(uint32_t model, PicoDrv **drvpp);
int RunBitFile(const char *bitFilePath, PicoDrv **drvpp);
int LoadFPGA(PicoDrv *pico, const char *bitFilePath);

int CreateStream(PicoDrv *pico, int streamNum);
void CloseStream(PicoDrv *pico, int streamHandle);

int ReadStream(PicoDrv *pico, int streamHandle, void* buf, int size);
int WriteStream(PicoDrv *pico, int streamHandle, const void* buf, int size);
int GetBytesAvailable(PicoDrv *pico, int streamHandle, int forReading);

#ifdef __cplusplus
}
#endif
#endif /* _PICO_C_API_H_ */
