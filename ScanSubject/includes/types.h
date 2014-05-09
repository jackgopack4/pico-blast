
#ifndef _TYPE_H
#define _TYPE_H

#include "pico_types.h"

typedef unsigned char uchar;
typedef unsigned long ulong;
typedef unsigned short ushort;
// typedef unsigned char uint8_t;
// typedef unsigned short uint16_t;
// typedef unsigned long uint32_t;
// typedef unsigned long long uint64_t;
// typedef int size_t;               // this fails in linux -
#define size_t int

typedef unsigned int uint;

typedef volatile unsigned char vuchar;
typedef volatile unsigned short vushort;
typedef volatile unsigned long vulong;
typedef volatile unsigned int vuint;
typedef volatile int vint;
#endif
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
