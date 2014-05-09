// iocalls_linux.h - ioctl defs.

#ifndef _IOCALLS_POSIX_H_
#define _IOCALLS_POSIX_H_

#if defined(WIN32)
#include "pico_win_lib.h"
#include "linux_ioctl.h"
#elif !defined(BSD)
#include <linux/ioctl.h>
#endif

/*
 * Ioctl definitions
 */

/* Use 'p' as magic number */
#define PICO_IOC_MAGIC  'p'
#define PICO_MAGIC 0x5049434f	/* "PICO" */

/*
 * S means "Set" through a ptr,
 * T means "Tell" directly with the argument value
 * G means "Get": reply by setting through a pointer
 * Q means "Query": response is on the return value
 * X means "eXchange": switch G and S atomically
 * H means "sHift": switch T and Q atomically
 *
 * _IO(type,nr)             no arguments
 * _IOR(type,nr,datatype)   read data from driver
 * _IOW(type,nr.datatype)   write data to driver
 * _IORW(type,nr,datatype)  read/write data
 *
 * _IOC_DIR(nr)             returns direction
 * _IOC_TYPE(nr)            returns magic
 * _IOC_NR(nr)              returns number
 * _IOC_SIZE(nr)            returns size
 */

typedef enum { 
    PICO_IOC_NOP,					    // [00] DRV E12 E14 E16
    PICO_IOC_GVERSION,					// [01] DRV E12 E14 E16
    PICO_IOC_GSVERSION,		            // [02] DRV E14
    PICO_IOC_GETCONFIG,					// [03] DRV E12 E14 E16
    PICO_IOC_GETSETDBG,					// [04] DRV E14 
    PICO_IOC_GMETEST  ,					// [05] E16
    PICO_IOC_KEYHOLEENABLE,	            // [06] DRV E14 
    PICO_IOC_GETSTATISTICS,             // [07] DRV
    PICO_IOC_SETCHANNEL,				// [08] DRV E14 E16
    PICO_IOC_TIECHANNELS,				// [09] DRV E16
    PICO_IOC_READATTRMEM,				// [0a] DRV E12 E14
    PICO_IOC_WRITEATTRMEM,				// [0b] DRV E12 E14
    PICO_IOC_GMEBMREAD,					// [0c] DRV E14 E16
    PICO_IOC_GMEBMWRITE,				// [0d] DRV E14 E16
    PICO_IOC_READPORT,					// [0e] DRV E14
    PICO_IOC_WRITEPORT,					// [0f] DRV E14
    PICO_IOC_READMEM,					// [10] DRV E14
    PICO_IOC_WRITEMEM,					// [11] DRV E14
    PICO_IOC_READFLASH,		            // [12] DRV E14
    PICO_IOC_WRITEFLASHCMD,		        // [13] DRV E12 E14
    PICO_IOC_READKEYHOLE,	            // [14] E14
    PICO_IOC_WRITEKEYHOLE,	            // [15] DRV E14
    PICO_IOC_LOCKFORLOAD,                   // [16] DRV E16
    PICO_IOC_CFGFPGA,
    PICO_IOC_READ8111,
    PICO_IOC_WRITE8111,
    PICO_IOC_SETEXCL,
    PICO_IOC_GETPCIPATH,
    PICO_IOC_GETPICONUM,
    PICO_IOC_TIESTREAMS,
    PICO_IOC_BYTES_AVAILABLE,
    PICO_IOC_MAX	                    //
} IOC_TYPES;

typedef struct ixfr {
	unsigned int    sig;                    /* signature for validation */
	unsigned int    fcn;                    /* function code */
	void            *bP;                    /* buffer pointer */
	unsigned int    len;                    /* length */
	unsigned int    addr;                   /* address */
	int		        write;                  /* true if writing */
	int		        rc;                     /* return value */
} ixfr_t;

#if 1                                                                                                            // who is using them 
    #define PICO_IOCNOP       	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_NOP,             struct ixfr)					// DRV E12 E14 E16
    #define PICO_IOCGVERSION	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_GVERSION,        struct ixfr)					// DRV E12 E14 E16
    #define PICO_IOCGSVERSION           _IOWR(PICO_IOC_MAGIC, PICO_IOC_GSVERSION,       struct ixfr)		            // DRV E14
    #define PICO_IOCGETCONFIG	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_GETCONFIG,       struct ixfr)					// DRV E12 E14 E16
    #define PICO_IOCGETSETDBG           _IOWR(PICO_IOC_MAGIC, PICO_IOC_GETSETDBG,       struct ixfr)					// DRV E14 
    #define PICO_IOCGMETEST  	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_GMETEST,         struct ixfr)					// E16
    #define PICO_IOCKEYHOLEENABLE       _IOWR(PICO_IOC_MAGIC, PICO_IOC_KEYHOLEENABLE,   struct ixfr)	                // DRV E14 
    #define PICO_IOCGETSTATISTICS       _IOWR(PICO_IOC_MAGIC, PICO_IOC_GETSTATISTICS,   struct ixfr)                    // DRV
    #define PICO_IOCSETCHANNEL	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_SETCHANNEL,      struct ixfr)					// DRV E14 E16
    #define PICO_IOCTIECHANNELS	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_TIECHANNELS,     struct ixfr)					// DRV E16


//  #define PICO_IOCGETKEYHOLE          _IOWR(PICO_IOC_MAGIC, PICO_IOC_GETKEYHOLE,      struct ixfr)
//  #define PICO_IOCSENDKEYHOLE         _IOWR(PICO_IOC_MAGIC, PICO_IOC_SENDKEYHOLE,     struct ixfr)
//  #define PICO_IOCGETSTATUS	        _IOWR(PICO_IOC_MAGIC, PICO_IOC_GETSTATUS,       struct ixfr)                  
//  #define PICO_IOCLOADFPGA            _IOWR(PICO_IOC_MAGIC, PICO_IOC_LOADFPGA,        struct ixfr)                  


    #define PICO_IOCREADATTRMEM         _IOWR(PICO_IOC_MAGIC,PICO_IOC_READATTRMEM,      struct ixfr)					// DRV E12 E14
    #define PICO_IOCWRITEATTRMEM        _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEATTRMEM,     struct ixfr)					// DRV E12 E14
    #define PICO_IOCGMEBMREAD	        _IOWR(PICO_IOC_MAGIC,PICO_IOC_GMEBMREAD,        struct ixfr)					// DRV E14 E16
    #define PICO_IOCGMEBMWRITE	        _IOWR(PICO_IOC_MAGIC,PICO_IOC_GMEBMWRITE,       struct ixfr)					// DRV E14 E16
    #define PICO_IOCREADPORT	        _IOWR(PICO_IOC_MAGIC,PICO_IOC_READPORT,         struct ixfr)					// DRV E14
    #define PICO_IOCWRITEPORT	        _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEPORT,        struct ixfr)					// DRV E14
    #define PICO_IOCREADMEM	            _IOWR(PICO_IOC_MAGIC,PICO_IOC_READMEM,          struct ixfr)					// DRV E14
    #define PICO_IOCWRITEMEM	        _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEMEM,         struct ixfr)					// DRV E14
    #define PICO_IOCREADFLASH           _IOWR(PICO_IOC_MAGIC,PICO_IOC_READFLASH,        struct ixfr)		            // DRV E14
    #define PICO_IOCWRITEFLASHCMD       _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEFLASHCMD,    struct ixfr)		            // DRV E12 E14
    #define PICO_IOCREADKEYHOLE         _IOWR(PICO_IOC_MAGIC,PICO_IOC_READKEYHOLE,      struct ixfr)		            // E14
    #define PICO_IOCWRITEKEYHOLE        _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEKEYHOLE,     struct ixfr)		            // DRV E14
    #define PICO_IOCLOCKFORLOAD         _IOWR(PICO_IOC_MAGIC,PICO_IOC_LOCKFORLOAD,      struct ixfr)
    #define PICO_IOCCFGFPGA             _IOWR(PICO_IOC_MAGIC,PICO_IOC_CFGFPGA,          struct ixfr)
    #define PICO_IOCREAD8111            _IOWR(PICO_IOC_MAGIC,PICO_IOC_READ8111,         struct ixfr)
    #define PICO_IOCWRITE8111           _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITE8111,        struct ixfr)
    #define PICO_IOCSETEXCL             _IOWR(PICO_IOC_MAGIC,PICO_IOC_SETEXCL,          struct ixfr)
    #define PICO_IOCGETPCIPATH          _IOWR(PICO_IOC_MAGIC,PICO_IOC_GETPCIPATH,       struct ixfr)
    #define PICO_IOCGETPICONUM          _IOWR(PICO_IOC_MAGIC,PICO_IOC_GETPICONUM,       struct ixfr)
    #define PICO_IOCTIESTREAMS          _IOWR(PICO_IOC_MAGIC,PICO_IOC_TIESTREAMS,       struct ixfr)
    #define PICO_IOCBYTESAVAILABLE      _IOWR(PICO_IOC_MAGIC,PICO_IOC_BYTES_AVAILABLE,  struct ixfr)

//  #define PICO_IOCLASTREGS            _IOWR(PICO_IOC_MAGIC,PICO_IOC_LASTREGS,         struct ixfr)  
//  #define PICO_IOCSETFPGALOADFILE     _IOWR(PICO_IOC_MAGIC,PICO_IOC_SETFPGALOADFILE,  struct ixfr)
//  #define PICO_IOCGETFPGALOADFILE     _IOWR(PICO_IOC_MAGIC,PICO_IOC_GETFPGALOADFILE,  struct ixfr)
//  #define PICO_IOCORIGINALCIS         _IOWR(PICO_IOC_MAGIC,PICO_IOC_ORIGINALCIS,      struct ixfr)	
//  #define PICO_IOCBMSTAT              _IOWR(PICO_IOC_MAGIC,PICO_IOC_BMSTAT,           struct ixfr)
//  #define PICO_IOCWHEREAMI            _IOWR(PICO_IOC_MAGIC,PICO_IOC_WHEREAMI,         struct ixfr)
//  #define PICO_IOCGETSETDEVICEPARAMS  _IOWR(PICO_IOC_MAGIC,PICO_IOC_GETSETDEVICEPARAMS, struct ixfr)
//  #define PICO_IOCWRITEREADJTAG       _IOWR(PICO_IOC_MAGIC,PICO_IOC_WRITEREADJTAG,    struct ixfr)

#else
    #define PICO_IOCGENERIC            _IOWR(PICO_IOC_MAGIC,0, struct ixfr)
#endif

/*  for the moment these deliberately coorespond to the minor numbers */

#define MINOR_SHIFT     3	// room for 8 minor dev numbers per e16
#define MINOR_COUNT		(1 << MINOR_SHIFT)
#define MINOR_MEM       0
#define MINOR_IO        1
#define MINOR_CFG       2
#define MINOR_FLASH     3
#define MINOR_LCS	    5
//#define MINOR_MEM	    2
// #define MINOR_LCS	0
#define MINOR_PICOBUS	6
#define MINOR_8111	    7
#define MINOR_CHAN      0x80000000

#define MAX_BARS        2
#define BAR_MEM		    0
#define BAR_IO		    1
#define BAR_CFG		    2

#if defined(BSD)
#define ERR(errno)              errno
#else
#define ERR(errno)              -errno
#endif

#endif // !_IOCALLS_POSIX_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
