#ifndef _PICO_DRV_H_
#define _PICO_DRV_H_

#include <always.h>
#include <pico_types.h>
#include <gstring.h>
#include <iocalls.h>

#define PICO_DDR3_0     0
#define PICO_DDR3_1     1

class PicoDrv
   {public:
                            PicoDrv         ();
        virtual             ~PicoDrv        () =0;
        
        // returns true if everything is working, false if not open, etc.
        virtual bool        Ok              () =0;
        virtual int         LoadFPGA        (const char *fileNameP, const uint8_t *dataP=NULL, int size=0)=0;
        
        virtual int         ReadDeviceAbsolute  (pico_size_t addr, void* buf, int size);
        virtual int         WriteDeviceAbsolute (pico_size_t addr, const void* buf, int size);

        virtual int         CreateStream    (int streamNum);
        virtual void        CloseStream     (int streamHandle)=0;
        virtual int         ReadStream      (int streamHandle, void* buf, int size)=0;
        virtual int         WriteStream     (int streamHandle, const void* buf, int size)=0;
        virtual int         GetBytesAvailable(int streamHandle, bool isRead=true);

        virtual int         ReadRam         (uint64_t addr, void* buf, int size, int memID = PICO_DDR3_0);
        virtual int         WriteRam        (uint64_t addr, const void* buf, int size, int memID = PICO_DDR3_0);
        
        virtual int         GetPicoConfig   (PICO_CONFIG *);
        virtual int         GetSerial       ();
        virtual int         GetSlot         (char *buf, int bufSize);
        virtual int         GetSysMon       (float *temp, float *voltage, float *current);

        /**********************************************************************************
         * DEPRECATED FUNCTIONS - THESE WILL CONTINUE TO BE SUPPORTED BUT NEW CODE SHOULD *
         *     USE THE FUNCTIONS ABOVE                                                    *
         **********************************************************************************/
        virtual int         GetError        ();
        virtual uint32_t    GetDebugFlags   (uint32_t persistent=0);
        virtual uint32_t    SetDebugFlags   (uint32_t flags);
        virtual int         GetStatistics   (uint32_t* regs, int regcnt);
        virtual int         TieStreams      (int streamNumA, PicoDrv *picoB, int streamNumB);
        virtual int         CreateChannel   (int channelNum);
        virtual int         BytesAvailable  (uint32_t channelNo, bool isRead);
        virtual int         ReadDevice      (pico_size_t addr, void* buf, int size) =0;
        virtual int         WriteDevice     (pico_size_t addr, const void* buf, int size) =0;
        virtual int         BMRead          (uint32_t card_addr, uint32_t *pc_addr, uint32_t len);// {return -ERR_0997;}
        virtual int         BMWrite         (uint32_t card_addr, uint32_t *pc_addr, uint32_t len);// {return -ERR_0997;}
        virtual int         BMwait          (int counter=16)                                     ;// {return -ERR_0997;}
        virtual int         GMEBMRead       (void *pcAddr, uint32_t cardAddr, uint32_t len);
        virtual int         GMEBMWrite      (void *pcAddr, uint32_t cardAddr, uint32_t len);
        // erases sectors. sectorsP is a -ve terminated list of sector numbers.
        virtual int         ErasePhysicalSectors(int *sectorP, int count);
        // returns a string describing the driver, its compilation date, etc.
        virtual const char* GetDesc         (char *bufP, int bufSize) =0;
        virtual int         GetMagicNum     (uint32_t* magicNumP);
        virtual int         GetPCIPath      (char *bufP, int bufSize);
        virtual int         GetRawKeyholeData(KEYHOLE_BUF *keyP, bool enable=true);
        virtual bool        IsSimulationFile(void);
        virtual bool        PastEOF         (FLASHROM_ADDR);
        virtual int         ReadE16eeProm   (uint32_t adr, void* bufP, int len);
        virtual int         WriteE16eeProm  (uint32_t adr, void* bufP, int len);
        virtual int         ReadPLX8111Regs (pico_size_t addr, void* buf, int size=sizeof(uint32_t));
        virtual int         ReadFlash       (pico_size_t addr, void* buf, int size);
        virtual int         ReadAttributeMemory (int adr, void* bufP, int sizeofBuf);
        virtual int         ReadHobbledMode (void);
        virtual int         ReadOriginalCIS (void* bufP, int count);
        virtual int         ReadPort        (int portAdr, void *vP, int byteCount=2);
        virtual int         ReadSnippet     (FLASHROM_ADDR, void* bufP, int bufSize, int sizeSnippet, int sectorSize);
        virtual int         ReadSnippets    (uint8_t *snippetBufP, int sizeSnippetBuf, int snippetSize);
        virtual int         SendKeyholeCmd  (KEYHOLE_BUF * , int);
        virtual int         WritePLX8111Regs(pico_size_t addr, const void* buf, int size=sizeof(uint32_t));
        virtual int         WriteAttributeMemory(int adr, void* bufP, int sizeofBuf);
        virtual int         WriteFlashCmd   (FLASH_CMD *cmdP, int count);
        virtual int         WriteReadJtag   (uint32_t ctrl, uint8_t *tdiP, uint8_t *tdoP, int bitCount, int dvcsBfor, int dvcsAft, const char*);
        virtual int         WritePort       (int portAdr, const void *vP, int byteCount=2);
        virtual int         SetExclusiveMode(bool excl);
        virtual int         SetPicoAddr     (int fileNo, uint32_t tag);
    
    protected:
        virtual int         InitDDR3        (int memID);
        virtual int         ResetDDR3       (int memID);

        // initialized by pico_drv_linux.cpp
        int         m_memStreams[3];
        PICO_CONFIG         m_cfg;
   };

int PowerCycle(uint32_t model, uint64_t port, int dvcNo);
int FindPico(const PICO_CONFIG *target, PicoDrv **drvpp);
int FindPico(uint32_t model, PicoDrv **drvpp);
int RunBitFile(const char *bitFilePath, PicoDrv **drvpp);
int BitFileCompat(const char *fname, const PICO_CONFIG *cfg);
int GetPicoSlot(PicoDrv *pico, char *buf, int bufSize);
int SetClk(PicoDrv* drv, int dcm_inx, int speed);
int DNA2Serial(uint64_t dna);

typedef struct
   {uint32_t writeData :8,  //bits 0-7
             readData  :8,  //bits 8-15
             writeStart:1,  //bit  16 when set, the value in the serial eeprom write data field is written to the serial eeprom.
                            //        automatically cleared when the write operation is complete.
             readStart :1,  //bit  17 when set, a byte is read from the serial eeprom, into the read data field of EECTL.
             enable    :1,  //bit  18 when set, the serial eeprom chip select is enabled.
             busy      :1,  //bit  19 when set, the serial eeprom controller is busy performing a byte read or write operation.
             valid     :1,  //bit  20 set when a serial eeprom with 5Ah in the first byte is detected.
             present   :1,  //bit  21 set when the serial eeprom controller determines that a serial eeprom is connected to the 8311.
             active    :1,  //bit  22 set when the eecs# ball to the serial eeprom is active. the chip select can be active across
                            //        multiple byte operations.
             width     :2,  //bits 23-24 units=bytes
             reserved  :6,  //bits 23
             reload    :1;  //bit  31 When written causes the eeprom to reload its valus to the 8111.
   } EECTL_REG;

class cEE
   {private:
    #define EE_READ_STATUS_OPCODE    5       //written to EECTL to request status
    #define EE_WREN_OPCODE           6       //written to EECTL to enable writing
    #define EE_WRITE_OPCODE          2       //written to EECTL to write address & data
    #define EE_READ_OPCODE           3       //written to EECTL to read data
    class PicoDrv  *m_drvP;
    EECTL_REG ReadEEregister(void);
    void      DisableEE     (void);
    uint8_t   ReadByte      (void);
    void      WriteByte     (int val);
    public:
    bool      m_errorB;
    cEE(PicoDrv *drvP) {m_drvP = drvP; m_errorB = false;}
    uint8_t   Status   (void);                          //get status of EEprom
    int       Write    (int addr, void *bufP, int len); //read  multiple bytes
    int       Read     (int addr, void *bufP, int len); //write multiple bytes
    bool      ReadEm   (EECTL_REG *eeCtlP);
    bool      WriteEm  (EECTL_REG eeCtl);
   }; //cEE...

#endif // _PICO_DRV_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
