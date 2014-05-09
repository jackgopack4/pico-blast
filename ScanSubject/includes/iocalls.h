/* ===================================================================================
 File: iocalls.h. Version 4.0.1.3. Sep 15, 2007.

 IOcalls.h - the external interface for applications to call the O/S driver (pico.sys).

 This files defines the specific constants and structures passes between an application
 program and the O/S driver. This is typically wrapped by either pico.dll or pico_channel.cpp

 Other defines include the port address for various functions implemented inthe firmware.
 ===================================================================================== */

#ifndef __IOCALLS_H
#define __IOCALLS_H

#if !defined(STARBRIDGE) //{
    #if !defined(CTL_CODE) && !defined(__KERNEL__) && !defined(_KERNEL)
        #ifndef PICO_WIDGETS
            #include <windows.h>
            #undef Yield
        #endif
        #include <winioctl.h>
    #endif
    #include <pico_types.h>
#endif //!STARBRIDGE }

#if defined(_WIN32)
 #pragma pack(push,1)   //1byte packing
 #define PACKED 
#elif defined(__GNUC__)
 #pragma pack(push,1)   //1byte packing
 #define PACKED __attribute__ ((packed))        // or specify packing by individual struct or even struct element
 // #define PACKED __attribute((packed))
#else
 #warning "unsupported OS/compiler"
#endif
#if defined(POSIX) 
    #define DEVICE_NAME "/dev/pico0" // the m is redundant. this is not new. the only thing that's used the 'm' postfix in 2007 is the old drivers.
    #define ENV_PICODEV "PICODEV"
#elif defined(_WIN32_WCE) //gme changed this from checking the value to just checking for a def. ok?
    #define DEVICE_NAME "SYN0:"
#else
    #define DEVICE_NAME "\\\\.\\PicoX" //File name for : CreateFile("\\\\.\\PicoX",....)
#endif

#define DRIVER_NAME          "Pico"     //drivername on error/debug messages.

//*------------------- Start of control codes ----------------- {
// Device type 0x8100 is int "User Defined" range (32768 - 65535)
//Control codes have the following structure.
typedef struct {UINT32 method:2,
                       function:12, //0x800 +
                       access:2,
                       deviceType:16;} PACKED _JUST_FOR_DOCUMENTATION;

#define THE_CODE(opcode,access) CTL_CODE(0x8100, 0x940+(opcode), METHOD_BUFFERED, access)
//                              CTL_CODE(dvcType, fnction,       method,          access )

#define PICO_VERSION                 THE_CODE(0x06, FILE_READ_ACCESS)   //Return version
#define PICO_READ_SNIPPETS           THE_CODE(0x07, FILE_READ_ACCESS)   //read a few bytes from each sector (used by BuildDirectory)
#define PICO_READ_REG                THE_CODE(0x08, FILE_READ_ACCESS)   //Read Pico register
#define PICO_WRITE_REG               THE_CODE(0x09, FILE_WRITE_ACCESS)  //Write Pico register
#define PICO_WRITE_DEVICE            THE_CODE(0x0A, FILE_WRITE_ACCESS)  //Write Pico (flash) memory could use METHOD_IN_DIRECT
#define PICO_READ_FLASH              THE_CODE(0x0B, FILE_READ_ACCESS)   //Read  Pico (flash) memory could use METHOD_OUT_DIRECT
#define PICO_SET_MEMORY_SPEED        THE_CODE(0x0C, FILE_WRITE_ACCESS)  //
#define PICO_FLASH_STATUS            THE_CODE(0x0D, FILE_WRITE_ACCESS)  //get back Pico Flash Status
#define PICO_WRITE_FLASH_CMD         THE_CODE(0x0E, FILE_ANY_ACCESS)    //write series of commands
#define PICO_READ_DEVICE             THE_CODE(0x0F, FILE_READ_ACCESS)   //Read  Pico (flash) memory could use METHOD_OUT_DIRECT
#define PICO_GET_LPTNO               THE_CODE(0x10, FILE_WRITE_ACCESS)  //
#define PICO_HOBBLED                 THE_CODE(0x11, FILE_WRITE_ACCESS)  //get flag signalling sub-optimal mode.
#define PICO_PPC_TO_PC_KEYHOLE       THE_CODE(0x12, FILE_WRITE_ACCESS)  //
#define PICO_PC_TO_PPC_KEYHOLE       THE_CODE(0x13, FILE_WRITE_ACCESS)  //
#define PICO_KEYHOLE_ENABLE          THE_CODE(0x14, FILE_WRITE_ACCESS)  //
#define PICO_READ_CIS                THE_CODE(0x15, FILE_READ_ACCESS)   //
#define PICO_WRITE_CIS               THE_CODE(0x16, FILE_WRITE_ACCESS)  //
#define PICO_READ_PORT               THE_CODE(0x17, FILE_READ_ACCESS)   //
#define PICO_WRITE_PORT              THE_CODE(0x18, FILE_WRITE_ACCESS)  //
#define PICO_ORIGINAL_CIS            THE_CODE(0x19, FILE_READ_ACCESS)   //
#define PICO_WRITEREAD_JTAG          THE_CODE(0x1A, FILE_WRITE_ACCESS)  //
#define PICO_GET_FPGA_LOADFILE       THE_CODE(0x1B, FILE_WRITE_ACCESS)  //
#define PICO_WHEREAMI                THE_CODE(0x1C, FILE_READ_ACCESS)   //
#define PICO_STATISTICS              THE_CODE(0x1D, FILE_WRITE_ACCESS)  //
#define PICO_TIMING_STATISTICS       THE_CODE(0x1E, FILE_READ_ACCESS)   //
#define PICO_SETGET_DEVICE_PARAM     THE_CODE(0x1F, FILE_WRITE_ACCESS)  //

#define PICO_GET_FLAGS               THE_CODE(0x20, FILE_READ_ACCESS )  //return debug information: &outbuf <- debug information, limitted by size of buf.
#define PICO_GET_CONFIG              THE_CODE(0x21, FILE_WRITE_ACCESS)  //return PICO_CONFIG
#define PICO_GME_BM_READ             THE_CODE(0x22, FILE_READ_ACCESS)   //
#define PICO_GME_BM_WRITE            THE_CODE(0x23, FILE_WRITE_ACCESS)  //
#define PICO_WRITE_LCS               THE_CODE(0x24, FILE_WRITE_ACCESS)  //Read  PLX registers (9056)
#define PICO_READ_LCS                THE_CODE(0x25, FILE_READ_ACCESS)   //Write PLX registers (9056)
#define PICO_WRITE_PLX8111           THE_CODE(0x26, FILE_WRITE_ACCESS)  //Read  PCI registers (8111)
#define PICO_READ_PLX8111            THE_CODE(0x27, FILE_READ_ACCESS)   //Write PCI registers (8111)
#define PICO_SET_FPGA_LOADFILE       THE_CODE(0x28, FILE_WRITE_ACCESS)  //Log FPGA file name in Driver (E16)
#define PICO_SET_PICOADR             THE_CODE(0x29, FILE_WRITE_ACCESS)  //
#define PICO_BYTES_AVAILABLE         THE_CODE(0x2A, FILE_WRITE_ACCESS)  //

#define PICO_SET_FLAGS               THE_CODE(0x30, FILE_WRITE_ACCESS)  //set debugging toggle: inbuf16[0] = new debug value. !=0 gather debugging data

//*------------------- End of control codes ----------------- }

//*------------------- PLX Addrs for the E16 ----------------
const uint32_t PLX_LAS0RR   = 0x00;
const uint32_t PLX_LAS0BA   = 0x04;
const uint32_t PLX_LBRD0    = 0x18;
const uint32_t PLX_INTCSR   = 0x68;
const uint32_t PLX_CNTRL    = 0x6C;
const uint32_t PLX_DMAMODE0 = 0x80;
const uint32_t PLX_DMAPADR0 = 0x84;
const uint32_t PLX_DMALADR0 = 0x88;
const uint32_t PLX_DMASIZ0  = 0x8C;
const uint32_t PLX_DMADPR0  = 0x90;
const uint32_t PLX_DMACS    = 0xA8;

//BAR registers
#define BAR_PICO_MEMORY  (0x004 * sizeof(uint32_t))
#define CACHE_SIZE_PICO  (0x003 * sizeof(uint32_t))
#define BAR_PICO_IO      (0x005 * sizeof(uint32_t))
#define BAR_LPT_IO       (0x03F * sizeof(uint32_t)) //NOTE: crosses cardbus function boundary.

#pragma pack(pop)

// struct for info about a specific card. This is filled out byt Pico.sys. It belongs in here in iocalls.h.
struct PICO_CONFIG
   {pico_version_t firmwareVer;     //+0 firmware version
    uint32_t       capabilities,    //+4 capabilities, OR-ed together.
                   model;           //+8 == 0xE12 or 0xE14 or E16
    uint16_t       lxCard,          //12 =='LX' or 'FX'
                   magicNum;        //14 == 0x5397
    uint32_t       portAdr,         //16 == port address
                   memAdr,          //20 == virtual memory base address
                   openCount,       //24 == number of programs attached to driver
                   shareAccess;     //28 == open mode
    uint64_t       physicalAdr;     //32 == physical address of memory space
    uint32_t       interrupt;       //38 == interrupt number
    int            lastError;       //40 == last error reported by Pico.sys
    uint32_t       startupError;    //44 == NTSTATUS code from startup of pico.sys
    // these next two fields have been added since the original PICO_CONFIG struct was defined. we've subtracted their size from the "description" field
    //  to attempt to keep the struct the same size.
    uint64_t       dna;             //48 "Device DNA" - the unique fpga id baked in at the factory
    uint32_t       serial;          //56 serial number assigned by Pico
    uint64_t       irq_count;       //60 # interrupts received for this card
    char           description[128-20];//60+ = description of driver
   };

typedef struct
   {struct {uint16_t  ready : 1,     //0x01 = ready
                      done  : 1,     //0x02 = done
                      retry : 1,     //0x04 = retry
                      stop  : 1,     //0x08 = stop
                      tout  : 1,     //0x10 = tout
                      fired : 1,     //0x20 = transfer initiated
                      nu    :10;} stat;
     uint16_t         rmdr;
     uint32_t         intrCount, missedIntr;
    } BM_STATUS;


typedef struct
   {UINT32 timeout1,              //timeout for first call
           timeout2;              //timeout for subsequent calls.
   } PICO_TIMEOUT;

//Standard bits of JTAG interface. Also used in commands to pico.sys.WriteReadJtag.
#define JTAG_TDI_BIT 0x01   //in data port of lpt
#define JTAG_TCK_BIT 0x02   //in data port of lpt
#define JTAG_TMS_BIT 0x04   //in data port of lpt
#define JTAG_TDO_BIT 0x10   //in stat port of lpt

#define JTAG_XIT_BIT 0x80   //signal transition to exit-[ir | dr] state at end of TDI sequence.
#define JTAG_PPC_BIT 0x40   //Special style of call used by PPC. It does not shift dvcsAft bits,
                            //and requires an extra TMS & TDI bit when writing to a register.
#endif  // __IOCALLS_H
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
