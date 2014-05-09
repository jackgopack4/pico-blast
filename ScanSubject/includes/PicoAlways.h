/*
============================================================================

     Public include file for PPC and Host side program.

     File: PicoAlways.h

     This file contains common defines for Power PC programs and for host side
     programs. Data structures are represented in both Hi-Lo (PPC) and Lo-Hi
     format based on #ifdef _PPC_

     Programmer: Robert Trout

     Copyright Pico Computing, Inc., 2007. All rights reserved.

============================================================================ */
#ifndef _PICO_ALWAYS_H_ //{
#define _PICO_ALWAYS_H_
#if !defined (_WIN32) && !defined(POSIX) //{
   #define _PPC_
#else
   #undef _PPC_
#endif //}

#include "pico_types.h"

#define JVERSION 0x05000900
#define JVERSION_ASCII "5.0.9.0"
//pico_version_t stores version information for pico products.
// there are four numbers in a version number - eg 3.1.4.0
// each may range from 0-255 since they are eight bits.
// they are stored with major number in the most significant byte, so you can compare version numbers.
#define PICO_MAJOR_VERSION(ver)       (((ver) >> 24) & 0xff)
#define PICO_MINOR_VERSION(ver)       (((ver) >> 16) & 0xff)
#define PICO_REVISION_VERSION(ver)    (((ver) >>  8) & 0xff)
#define PICO_COUNTER_VERSION(ver)     (((ver)      ) & 0xff)

#define PICO_MAX_CARDNO                     31 //\\.\Pico# # in the range 1 - PICO_MAX_DEVICES

//These are constants packed into various status registers just for sanity checking.
#define PCMCIA_PPC2PC_CMND_SIGNATURE     0x12U
#define PCMCIA_PPC2PC_STAT_SIGNATURE     0x23U
#define PCMCIA_PC2PPC_STAT_SIGNATURE     0x34U
#define PCMCIA_BM_READ_STATUS_SIGNATURE  0x26U
#define PCMCIA_BM_WRITE_STATUS_SIGNATURE 0x22U
#define PICO_READ_PACE_SIGNATURE         0x26U //preferred signature
#define PICO_WRITE_PACE_SIGNATURE        0x22U //preferred signature
#define OPB_PC2PPC_CMND_SIGNATURE        0x78U
#define OPB_PC2PPC_STAT_SIGNATURE        0x3CU
#define OPB_PPC2PC_STAT_SIGNATURE        0x1AU
#define PCMCIA_JTAGSPY_STAT_SIGNATURE    0x06U
#define PCMCIA_JTAGSPY_DATA_SIGNATURE    0x03U

 //Ports on Pico Card
 #define PICOPORT_JTAG                   0x0000  //Any port with 0x04 == 0 will do. +0=data, +1=status, +2=ctrl.
 #define PICOPORT_AER                    0x0004  //.0x0000FFFF = high order bits of next mem access.
 #define PICOPORT_SET_CARDNO             0x0006  //card select on multiple card: note can also be set with aer.0xFFFF0000
 #define PICOPORT_MAGIC_NUM              0x000C  //magic number
 #define PICO_MAGIC_NUM                  0x5397  //
 #define PICOPORT_RESET_PPC              0x000E  //one 16bit register. Send 0xDF to reset processor.
 #define PICOPORT_STATUS_RESET           0x000E  //general status(R) and flash reset(W) (one 16 bit register)
 #define PICOPORT_RESET                  0x000E  //flash reset(W)    (one 16 bit register) //preferred terminology
 #define PICOPORT_STATUS                 0x000E  //general status(R) (one 16 bit register) //preferred terminology
 #define PCMCIA_PPC2PC_KEYHOLE_CMND      0x0014  //command 16bit register for ppc2pc_fifo.
 #define PCMCIA_PPC2PC_KEYHOLE_DATA      0x001C  //data    32bit register for ppc2pc_fifo.
 #define PCMCIA_PC2PPC_KEYHOLE_CMND      0x0024  //command 16/32bit register for pc2ppc_fifo.
 #define PCMCIA_PC2PPC_KEYHOLE_DATA      0x002C  //data    32bit register for pc2ppc_fifo.
 #define PICOPORT_PEEKABOO               0x0034  //Only on E14. 27 bits = last address passed through CPLD.
 #define PICOPORT_REBOOT                 0x003C  //Only on E14. 8  bits. see CPLD_CONTROLLER_RELOAD_PASSWORD.
 #define PICOPORT_VERSION                0x0044  //Only on E14. 32 bits
 #define PICOPORT_CAPS                   0x004C  //Only on E14. 16 bits
  #define PICO_CAP_FLASH                  0x0001 // allows us to talk to the flash rom
  #define PICO_CAP_TURBOLOADER            0x0002 // allows us to reload the fpga and get the current image (peekaboo)
  #define PICO_CAP_KEYHOLE                0x0004 // PPC "keyhole" register and monitor.elf running.
  #define PICO_CAP_FPGALOADED             0x0008 // FPGA has been loaded
  #define PICO_CAP_BUSMASTERING           0x0010 // Image has bus mastering
  #define PICO_CAP_ADC                    0x0020 // Image has A/D and D/A
  #define PICO_CAP_PIC                    0x0040 // Image has programmable Interrupt Controller.
  #define PICO_CAP_JTAG_SPY               0x0080 // Image has JTAG spy (it always has JTAG support)
  #define PICO_CAP_ETHERNET               0x0100 // Image has Ethernet
  #define PICO_CAP_UARTLITE               0x0200 // Image has UART lite.
  #define PICO_CAP_GPIO                   0x0400 // Image has GPIO capabilities.
  #define PICO_CAP_MPORT_RAM              0x0800 // Image support multiport RAM
  #define PICO_CAP_HOBBLED                0x2000 // E-12 is using configuration memory to set AER (hobbled mode).
  #define PICO_CAP_KEYHOLE_RAW            0x4000 // raw keyhole hardware ignoring presence of monitor.elf
  #define PICO_CAP_MONITOR                0x8000 // monitor is running.
 #define PCMCIA_PPC2PC_KEYHOLE_STAT      0x0054  //status 32bit register for ppc2pc_fifo.
 #define PCMCIA_PC2PPC_KEYHOLE_STAT      0x005C  //status 32bit register for pc2ppc_fifo.
 #define PCMCIA_JTAGSPY_DATA             0x0064  //data    register for reading JTAG data from fifo
 #define PCMCIA_JTAGSPY_STAT             0x006C  //status  register for reading JTAG status from fifo
 #define PCMCIA_BM_PHYADDR               0x0074  //physical address in host memory to perform transfer
 #define PCMCIA_BM_BUSADDR               0x007C  //local bus mastering bus address to perform transfer
 #define PCMCIA_BM_CMND                  0x0084  //top 30 bits is length, bottom 2 bits is command:
  #define BM_WRITE_BIT                    0x0001 //1 = write (ie host->picocard)
  #define BM_READ_BIT                     0x0002 //2 = read (ie picoCard->host)
 #define PCMCIA_BM_RMDR                  0x0094  //how many bytes are left to transfer, only useful when stopped
 #define PCMCIA_BM_STAT                  0x008C  //readback B/M status:
  #define BM_STATUS_READY                 0x0001 // 0x01 = ready
  #define BM_STATUS_DONE                  0x0002 // 0x02 = done
  #define BM_STATUS_RETRY                 0x0004 // 0x04 = retry
  #define BM_STATUS_STOP                  0x0008 // 0x08 = stop
  #define BM_STATUS_TOUT                  0x0010 // 0x10 = timeout
  #define BM_STATUS_FIRED                 0x0020 // 0x20 = transfer initiated
 #define PCMCIA_GPIO_SETUP               0x00B4  //Controls direction of GPIO lines (R/W)
 #define PCMCIA_GPIO_DATA                0x00BC  //Data on GPIO lies (R/W)
 #define PCMCIA_SAMPLE_DATA              0x00FC  //data port for samples\counter-E12/E14.
 #define MEM_PERIPHERALS_COUNTER_ADDR    0x11000000
 #define BMTEST_CHANNEL                  0x1
 #define BM_MIN_COUNT32                  16      //minimum number of words transferred by DMA cycle

 //Defines associated with Bus Mastering channel allocation
 #define BM_CHANNEL_SIZE                0x100000U   //size of each device is one megabyte
 #define BM_CHANNEL_BASE                0x10100000U //address of BM devices [0x1xxxxxxx, 0x7FFFFFFF]. Channel 1 is 0x10100000
 #define BM_MAX_CHANNELS                1791U       //number of one meg channels that fit in the above address space
 #define BM_STATUS_BASE                 0x10000010U //status registers, channel 1 is 0x10000010.
 #define BM_STATUS_SIZE                 0x10U       //each channel has space for 4 * 32Bit registers.
 #define BM_CHANNEL_FROM_ADDR(addr)     (1+(addr - BM_CHANNEL_BASE) / BM_CHANNEL_SIZE)
 #define BM_CHANNEL_FROM_STATUS(addr)   (1+(addr - BM_STATUS_BASE)  / BM_STATUS_SIZE)
 #define BM_ADDR_FROM_CHANNEL(channel)  (BM_CHANNEL_BASE + (channel-1) * BM_CHANNEL_SIZE)
 #define BM_STATUS_FROM_CHANNEL(channel)(BM_STATUS_BASE  + (channel-1) * BM_STATUS_SIZE)

 //Addresses in attribute memory: 16 bit accesses, but each 16 bits only contains 8 bits of data.
 #define PICOATTRIB_AER                 0x0216  //PCMCIA I/O address extension register (pico control ports)
 #define PICOATTRIB_COR                 0x0270  //PCMCIA Configuration options register (pico control ports)
 #define PICOATTRIB_VERSION             0x0400  //Firmware version (four addresses).
 #define PICOATTRIB_CAPS                0x0408  //Capabilities (two addresses). See PICO_CAP_xxxx.
 #define PICOATTRIB_RELOAD              0x0410  //Reload. see CPLD_CONTROLLER_RELOAD_PASSWORD
 #define PICOATTRIB_PEEKABOO            0x0414  //Last address, four addresses: last address passed through CPLD.
 #define PPC_SYSRST_PASSWORD              0xDF  //write 0xDF output to PICOPORT_RESET_PPC causes PPC to reset.
 #define CPLD_CONTROLLER_RELOAD_PASSWORD  0xAD  //output this to PICOPORT_REBOOT (E14) or write to PICOATTRIB_RELOAD (E12)
                                                //will reload FPGA image starting at next address accessed.
 #define FLASH_RESET_PASSWORD           0xDEAF  //write 0xDEAF restarts image starting at next address accessed.
 //Addresses in common memory
 #define PICOMEMORY_GPIO_SETUP_E12  0xFFFF0000  //GPIO Setup Register one 16 bit word
 #define PICOMEMORY_GPIO_XFACE_E12  0xFFFF0002  //GPIO Interface 14 * 16 bit words.
 //bits of PICOPORT_STATUS register
 #define PICO_FLASH_READY               0x0001  //write/erase has completed.
 #define PICO_FLASH_RESET               0x0001  //write to PICO_STATUS_RESET resets flash
 #define PICO_DCMS_LOCKED               0x0002  //DCMS have locked up on reset (that's good).

 #define E12_WINDOW_BITS                    11
 #define E14_WINDOW_BITS                    16  //or E-15
 #define E16_WINDOW_BITS                    20
 //Following maps from E14/15 port terminology to E16 memory mapped terminology
 #define PICOE16_CTRL_ADDR(oldPort)    (0xFFE00000 | (oldPort & ~3))

 //Following maps IO ports to memory mapped addresses on E-16
 #define E16_MEMORYMAPPED_BASE     0xFFE00000
 #define E16_PORT2MEM(portAdr)    (E16_MEMORYMAPPED_BASE + (portAdr & ~3))

#define MAX_WORDS_PER_KEYHOLE_PACKET 130   //theoretical max=258

typedef int FLASH_HANDLE;
typedef enum {FILETYPE_BIT, FILETYPE_ELF, FILETYPE_DATA, FILETYPE_UNKNOWN} FILE_TYPES;

#ifdef _PPC_ //{
 #ifndef BOOL //{
  #define BOOL  int
  #define TRUE  1
  #define FALSE 0
 #endif //} }
 #ifndef NULL
  #define NULL  0
 #endif
 #define HOWMANY(a) (sizeof(a)/sizeof((a)[0]))

 //Following error codes are used by Monitor.c (PPC monitor program)
 //They recapitulate the defines in Pico_errors.h, but since they are straight
 //thru defines the duplication is not too serious.
 #define ERR_0003    3 //File not found
 #define ERR_7200 7200 //error writing to memory
 #define ERR_7201 7201
 #define ERR_7202 7202
 #define ERR_7203 7203
 #define ERR_7204 7204
 #define ERR_7205 7205
 #define ERR_7206 7206 //Ending program
 #define ERR_7209 7209 //Starting program
 #define ERR_7210 7210 //Out of sequence %1X[%08X], status=%2X, count=%08X
 #define ERR_7211 7211 //No input received from PC, input stat=%02X
 #define ERR_7212 7212 //Incomplete command received from PC, stat=%02X
 #define ERR_7213 7213 //Out of sequence %1X[%08X], status=%2X, count=%08X
 #define ERR_7214 7214 //Out of sequence %1X[%08X], status=%2X, count=%08X
 #define ERR_7215 7215 //Too many parameters provided by PC
 #define ERR_7216 7216 //Invalid comand received.
 #define ERR_7217 7217 //exit from test program with command received
 #define ERR_7219 7219 //ram error
 #define ERR_7221 7221 //must be type bit
 #define ERR_7222 7222 //must be type elf

 // ----------------- PPC Hi-Lo format -----------------
 //The 32bit keyhole datum has the following structure:
 typedef struct
   {union {uint32_t         u32;
           struct {uint32_t asci0:8,        //.000000FF bits
                            asci1:8,        //.0000FF00 bits
                            asci2:8,        //.00FF0000 bits
                            asci3:8;};      //.FF000000 bits
           struct {uint32_t portNo:16,      //.FFFF0000 bits port
                            packetType:6,   //.0000FC00 bits KHC_values
                            byteCount:10;   //.000003FF bits number of 36bit words
                  };
           //following used by KoutputByte to transfer a single byte
           struct {uint32_t _portNo:16,     //.FFFF0000 bits
                            _packetType:6,  //.0000FC00 bits = 18 (KHC_SINGLEBYTE)
                            priority:2,     //.00000300 bits 1=high, 2=low, 0 & 3 = normal
                            singleByte:8;   //.000000FF bits character to output
                  };
          } d;
   } KEYHOLE_BUF;

 //The status port contains a counter and the status of the fifo.
 typedef struct
   {uint32_t signature:7, //OPB_PPC2PC_STAT_SIGNATURE or OPB_PC2PPC_STAT_SIGNATURE
             rdAdr    :9, //read address in fifl (E14 only)
             count    :9, //number of elements in fifo (E14 only)
             cmd      :4, //command field from other side
             stat     :3; //see enum KHS_FULL etc. below.
   } KEYHOLE_STAT;

  //Information passed to program when it is executed.
 typedef struct _BOARD_INFO
   {uint32_t  bi_signature;       // 0x00 valid bi signature
    uint32_t  bi_memMax;          // 0x04 DRAM installed, maximum byte address
    uint32_t  bi_intfreq;         // 0x08 Processor speed, in Hz
    uint32_t  bi_busfreq;         // 0x0C PLB Bus speed, in Hz
    uint32_t  bi_version;         // 0x10 local pico number format #.##, eg 3.09
    uint8_t  *bi_cmdline;         // 0x14
    uint32_t  bi_capabilities;    // 0x18 Pico capabilities mask
    uint32_t  bi_debug;           // 0x1C Pico flags mask
    uint32_t  bi_flashstart;      // 0x20 start of FLASH memory
    uint32_t  bi_flashsize;       // 0x24 size  of FLASH memory
    uint32_t  bi_envSize;         // 0x28 environment size
    uint8_t   bi_enetaddr[6];     // 0x2C Local Ethernet MAC address
    uint16_t  bi_cflags;          // 0x32 console flags
    char     *bi_envP;            // 0x34 pointer to environment string
    uint32_t  bi_model;           // 0x38 0x0E16'FX', (ie 0x0E164658) etc
    uint32_t  bi_resv;            // 0x38 reserved
   } BOARD_INFO;                  // 0x40


 //Following structure enables a loaded program to access basic routines in monitor.elf.
 typedef struct
   {int         (*m_kprintf)                   (const char *fmtP,...);
    int         (*m_getSetDebug)               (int newBug);
    uint32_t    (*m_monitorWait)               (int milliseconds);
    int         (*m_errorl)                    (int erC, const char *contextP, uint32_t param);
    BOOL        (*m_keyholeMessageReady)       (void);
    int         (*m_processKeyholeMessage)     (BOOL allowExec);
    FLASH_HANDLE(*m_nextFile)                  (FLASH_HANDLE handle, uint32_t *fileTypeP, uint32_t *fileSizeP);
    FILE_TYPES  (*m_getFileHeader)             (FLASH_HANDLE handle, char *headerP, int headerSize);
    FLASH_HANDLE(*m_openFile)                  (const char *fileNameP);
    int         (*m_readFile)                  (FLASH_HANDLE handle, uint32_t offset, void *bufP, uint32_t byteCount);
    int         (*m_loadBitFile)               (const char *flashFileNameP);
    int         (*m_loadElfFile)               (const char *flashFileNameP);
    BOARD_INFO *(*m_getBoardInfo)              (void);
    char *      (*m_getEnvironmentValue)       (const char *variableP);
    char *      (*m_getEnvironmentNameAndValue)(int index);
    int         (*m_uartPrintf)                (const char *fmtP,...);
   } KERNEL_LINKS;

 #define KernelLinksP             ((KERNEL_LINKS*)*((uint32_t*)0xFFFFFFF8))
 #define KERNEL_LINK(routine)     ((KERNEL_LINKS*)*((uint32_t*)0xFFFFFFF8))->routine
 #define Kprintf                    KERNEL_LINK(m_kprintf)
 #define GetSetDebug                KERNEL_LINK(m_getSetDebug)
 #define MonitorWait                KERNEL_LINK(m_monitorWait)
 #define Errorl                     KERNEL_LINK(m_errorl)
 #define KeyholeMessageReady        KERNEL_LINK(m_keyholeMessageReady)
 #define ProcessKeyholeMessage      KERNEL_LINK(m_processKeyholeMessage)
 #define OpenFile                   KERNEL_LINK(m_openFile)
 #define NextFile                   KERNEL_LINK(m_nextFile)
 #define GetFileHeader              KERNEL_LINK(m_getFileHeader)
 #define ReadFile                   KERNEL_LINK(m_readFile)
 #define LoadBitFile                KERNEL_LINK(m_loadBitFile)
 #define LoadElfFile                KERNEL_LINK(m_loadElfFile)
 #define GetBoardInfo               KERNEL_LINK(m_getBoardInfo)
 #define GetEnvironmentValue        KERNEL_LINK(m_getEnvironmentValue)
 #define GetEnvironmentNameAndValue KERNEL_LINK(m_getEnvironmentNameAndValue)
 #define GetFileAttributes(handle, typeP, sizeP) NextFile((handle / SECTOR_SIZE) | 0x80000000, typeP, sizeP)
 #define Uprintf                    KERNEL_LINK(m_uartPrintf)

 //Following bit positions defined for debug variable (typically called GlobalDebug in PPC program)
   #define BUG_ELF_LOAD          0x00000001 //debug flags in monitor.sys
   #define BUG_ELF_USER          0x00000002 //             "       This can be set from PicoUtil / menu / options /Pico Debug / user
 //#define BUG_ELF_RFU           0x0000FFF0 //             "       These flags are reserved for user and can be set using PicoBuf +0x10 etc,
                                            //             "       or programmaticly using SetDebugFlags()
 ////driver debug flags are in   0x0FF00000 bits
 //#define BUG_DRIVER_SUMMARY    0x00200000 //debug of Pico.SYS
 //#define BUG_DRIVER_INTERRUPT  0x00400000 //       "
 //#define BUG_DRIVER_POWER      0x00800000 //       "
 //#define BUG_DRIVER_DETAIL     0x01000000 //       "
 //#define BUG_DRIVER_JTAG       0x02000000 //       "
 //#define BUG_DRIVER_KEYHOLE    0x04000000 //       "
 //#define BUG_DRIVER_BM         0x08000000 //       "
 ////general control bits are in 0xF0000000 bits
 //#define BUG_PERSISTENT        0x20000000 //saves value in registry (not implemented or used).
 //#define BUG_REPLACE           0x40000000 //flag for PicoXface::SetDebugFlags() to force replace rather than and/or
   #define BUG_QUIET             0x80000000 //monitor.elf does not report setting.

//Macros to help construct 32 bit opcodes on PPC
#define OP(opcode)  ((((uint32_t)(opcode)) & 0x3f) << 26)               //opcode  in upper  6 bits
#define XL(op, xop) (OP(op) | ((((uint32_t)(xop)) & 0x3ff) << 1))       //operand in lower 26 bits

#else //}...{

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

 // ----------------- Pentium Lo-Hi format -----------------
 //Keyhole is a 32 bit register with the following structure: (Pentium Lo-Hi format)
 typedef struct
   {union {uint32_t         u32;
           //following used by KH_BEGIN for beginning of packet
           struct {uint32_t byteCount:10,   //.000003FF bits number of bytes in packet (excluding KH_BEGIN and KH_END)
                            packetType:6,   //.0000FC00 bits KHC_command
                            portNo:16;      //.FFFF0000 bits port.
                  };
           //following used by Kprintf for formatted output
           struct {uint32_t asci3:8,        //.000000FF bits
                            asci2:8,        //.0000FF00 bits
                            asci1:8,        //.00FF0000 bits
                            asci0:8;};      //.FF000000 bits
           //following used by KoutputByte to transfer a single byte
           struct {uint32_t singleByte:8,   //.000000FF bits = character to output
                            priority:2,     //.00000300 bits = 1=high, 2=low, 0 & 3=normal
                           _packetType:6,   //.0000C000 bits = 2 (KH_BYTE)
                           _portNo:16;      //.FFFF0000 bits
          };      };
   } PACKED KEYHOLE_DATA;

//Following data returned in status ports.
typedef struct
   {uint32_t stat     :3, //
             cmnd     :4, //
             count    :9, //number of 36bit words in fifo
             rdAdr    :9, //location in fifo of next item
             signature:7; //
   } PACKED KEYHOLE_STATUS32;

 //Structure of data returned from driver
 typedef struct
   {KEYHOLE_DATA d;
    uint8_t      cmnd;   //command associated with data
   } PACKED KEYHOLE_BUF;

//status word for Bus Mastering port
typedef struct
  {UINT32 wordsAvailable:20,
          nu            : 6,
          signature     : 6; // == PCMCIA_BM_READ_STATUS_SIGNATURE (0x26) or PCMCIA_BM_WRITE_STATUS_SIGNATURE (0x22)
  } PACKED BM_DEVICE_STATUS;

//pacing register for Bus Mastering port preferred terminology
typedef struct
  {UINT32 wordsAvailable:20,
          nu            : 6,
          signature     : 6; // == PICO_READ_PACE_SIGNATURE (0x26) or PIC_WRITE_PACE_SIGNATURE (0x22)
  } PACKED PICO_PACE;

#pragma pack(pop)
#endif //_PPC_ }

enum {KHP_BROADCAST,   //0
      KHP_MONITOR,     //1 for monitor
      KHP_GDB,         //2 debugging output
      KHP_TTY3,        //3
      KHP_TTY4,        //4
      KHP_TTY5,        //5
      KHP_TTY6         //6
     };

//Values of cmd field in the CMND register.
enum {KH_BEGIN,        //=0 start of packet. u32 breaks out various cases (see KHC_xxx below)
      KH_DATA,         //=1 an integer element of a packet.
      KH_BYTE,         //=2 used by KoutputByte
      KH_NOTREADY,     //=3 Monitor was unable to send data because Fifo reported not ready
      KH_CONTROL,      //=4 used to pass control information through PC2PPC_CMND port
      KH_XFMTTED,      //=5 nu
      KH_LOSTX,        //=6
      KH_BLOCK,        //=7 nu
      KH_FINISHED,     //=8 Monitor has finished sending a message.
      KH_END=15};      //15 end of command sequence (fmtted I/O, block transfer, etc)
                       //   or used to send a single byte.
//Bits of status fields
enum {KHS_ALMOST_EMPTY=1, KHS_ALMOST_FULL=2, KHS_EMPTY=4, KHS_FULL=2}; //note full and almost full are the same.
//Values of KEYHOLE_DATA.packetType
enum {KHC_LOOPBACK=0,   // 0 used for testing
      KHC_RAMSIZE,      // 1 return size of RAM.
      KHC_VERSION,      // 2 retrieve version
   NU_KHC_TIMEOUT,      // 3 set timeout of keyhole
      KHC_LOAD_ELF,     // 4 load program. u32=starting sector
      KHC_RAM_TEST,     // 5 ram test (startAdr, startPattern, incrementPattern)
      KHC_READ_MEM,     // 6 read memory at address specified in param[0]
      KHC_FMTD,         // 7 start of formatted I/O
      KHC_ERR,          // 8 error, followed by error # & 32bit value.
      KHC_INTERNAL_TEST,// 9 internal test.
      KHC_EXITTEST,     //10 exit from test program
      KHC_DEBUG,        //11 set debug from param[0] != 0
      KHC_WRITE_MEM,    //12 param[0] = address, write upto 255 values into memory (RAM)
      KHC_CALL_MEM,     //13 call address at param[0]
      KHC_HALT,         //14 halt PPC
      KHC_CLEAR_MEM,    //15
      KHC_DUMP_MEM,     //16
      KHC_LOST,         //17 data was lost between Pico card and driver
      KHC_SINGLEBYTE,   //18 single byte (carried in KH_END element)
      KHC_SETENV,       //19 set environment variable
      KHC_TEST_RS232,   //20 trivial rs-232 test.
      KHC_STRING,       //21
      KHC_BLOCK,        //22
      KHC_LASTCMD       //23
     };
#define KHC_MISC KHC_INTERNAL_TEST
#define SECTOR_SIZE          0x2000                     //Logical sector size in Flash ROM.
#define DEVICE_SIZE_E12      0x04000000
#define FLASH_SIZE_E12       0x04000000                 //64Megabyte - thankfully the same for E12 and E14 ???
#define MAX_SECTORS_E12     (DEVICE_SIZE_E12 / SECTOR_SIZE)
#define OPB_FLASH_BASEADDR   0x60000000                 //Base address of Flash ROM
                                                        // (should equal XPAR_OPB_PICOE12_EPBASE_R1_0_AR2_BASEADDR)
#define OPB_CTRL_BASEADDR    0x70000020                 //Base address of control ports=0x70000020
#define OPB_CTRL_HIGHADDR    0x70000080                 //End  address of control ports=0x70000080
#define PPC_MASTER_ENABLE    OPB_CTRL_BASEADDR          //=1 enables PPC access to flash, =0 enables PC access to flash.
#define PPC_ACCESS_TYPE     (OPB_CTRL_BASEADDR+0x24)    //register for Little Brother controlling OPBmemBridge=0x70000044
#define OPB_PEEKABOO        (OPB_CTRL_BASEADDR+4)       //return last reboot address from CPLD input (I)= 0x70000024.
#define OPB_REBOOT          (OPB_CTRL_BASEADDR+4)       //set reboot latch in CPLD output (O)           = 0x70000024.
#define PPC_RAM_BASEADDR     0x00000000                 //Base address of RAM.
#define PPC_RAM_SIZE_E12     0x08000000                 //E-12 size = 128 Mbytes
#define PPC_RAM_SIZE_E14     0x10000000                 //E-14 size = 256 Mbytes.
#define PPC_RAM_SIZE_E16     0x02000000                 //E-16 size =  32 Mbytes.
#define PPC_RAM_CHUNK        0x01000000                 //For ram tests and clear ram
#define PPC_RAM_CHUNK_DUMP   0x00100000                 //For dump ram
#define OPB_BM_TEST          0x70000100

//------------------------- PPC keyhole ports (memory mapped)
#define OPB_KEYHOLE_BASEADDR  0x70000000
#define OPB_PPC2PC_CMND       0x70000000                //command register for ppc2pc_fifo (write only) = 0x70000000.
#define OPB_PPC2PC_DATA       0x70000004                //data    register for ppc2pc_fifo (write only) = 0x70000004.
#define OPB_PPC2PC_STAT       0x70000008                //status  register for ppc2pc fifo (read  only) = 0x70000008.
#define OPB_KEYHOLE_MISC      0x7000000C                //misc    register for keyhole debugging        = 0x7000000C.
//------------------------- PC keyhole ports (IO ports)
#define OPB_PC2PPC_CMND       0x70000010                //command register for pc2ppc_fifo (read  only) = 0x70000010.
#define OPB_PC2PPC_DATA       0x70000014                //data    register for pc2ppc_fifo (read  only) = 0x70000014.
#define OPB_PC2PPC_STAT       0x70000018                //status  register for pc2ppc fifo (read  only) = 0x70000018.
#define OPB_GENERAL_STATUS    0x70000028                //status bits                                   = 0x70000028.
#define OPB_CAPABILITIES      0x7000002C                //status bits                                   = 0x7000002C.
#define OPB_BUSBRIDGE_WINDOW_REG_ADDR  0x70000030       //Specifies address window from PPC side.
#define OPB_BUSBRIDGE_ACCESS_TYPE_ADDR 0x70000034       //0=normal memory access, 1=attribute memory access, 2=port access
#define OPB_SAMPLE_DATA       0x70000FC0
#define OPB_COUNTER			  0x70000038			    //JBC- counter used for standalone				= 0x70000038.
#define OPB_COUNTER_25		  0x7000003C			    //JBC- counter used for standalone				= 0x7000003C.
	
//-------------------------- DataLock ports  (memory mapped)
#define OPB_PPC2PC_LOCK_DATA  (OPB_KEYHOLE_BASEADDR+0x50) //location of lock register for PPC->pc         = 0x70000050
#define OPB_PC2PPC_LOCK_DATA  (OPB_KEYHOLE_BASEADDR+0x54) //location of lock register for pc->ppc         = 0x70000054

//-------------------------- Interrupt remapping area: 0x70010000 - 0x70012000
#define OPB_PPC_INTERRUPT_MAP 0x70010000

//bits of PICOPORT_STATUS_RESET register
 #define PICO_FLASH_READY             0x0001  //write/erase has completed.
 #define PICO_FLASH_RESET             0x0001  //write to PICO_STATUS resets flash
 #define PICO_DCMS_LOCKED             0x0002  //DCMS have locked up on reset (that's good).
 #define PICO_STANDALONE_SW           0x8000  //monitor has detected loopback jumper on pcmcia/cardbus bus.

 //Following structure at the beginning of each sector
typedef struct
   {uint32_t linkAdr;     //hi-lo format
    uint8_t  nu[3],
             flag;        //== '*' at start of file
   }FILE_LINK_WORD;

#define FIRST_FILE_ADDR   (2*SECTOR_SIZE)     //first address on which a file can be written (usually is primaryBoot.bit)
#define BOOT_PRIMARY_FAST (FIRST_FILE_ADDR+1) //Command to Reboot to reload PrimaryBoot.bin and power cycle if there is a problem.
#define BOOT_POWER_CYCLE  (FIRST_FILE_ADDR+2) //Command to Reboot to power cycle card.
#define BOOT_ABSOLUTE_ADR  3                  //addr+3 signals reboot from absolute flash ROM address

#define SERIALNO_OFFSET (256-32)   //location of serial number in flash ROM
typedef struct {uint8_t version; uint8_t trash[3]; uint8_t serial[8]; uint8_t fpgaModel[16]; uint8_t nu[4];} SERIAL_STRUCT;

#define PICO_FLAG_CONSOLE_UARTLITE 1
#define PICO_FLAG_CONSOLE_KEYHOLE  2
#define PICO_FLAG_CONSOLE_CRLF 4
#define PICO_FLAG_CONSOLE_ECHO 8

//recent versions of GCC have deliberately limited offsetof and recommend the following as a replacement /dhl/
#define Offsetof(s,m) ((uint32_t)((char*)&(((s *)0)->m)-(char*)0))

#endif // _PICO_ALWAYS_H_ }

#define PLX_CHANNEL0_DONE 0x10
//end of file
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
