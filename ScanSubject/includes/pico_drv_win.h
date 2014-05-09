/* pico_drv_win.h
 * Interface to the Windows pico driver.
 */

#ifndef _PICO_DRV_WIN_H_
#define _PICO_DRV_WIN_H_

#include <stdio.h>
#include <stdint.h>
#include "wdc_defs.h"
#include "wdc_lib.h"
#include "utils.h"
#include "status_strings.h"
#include <limits.h>
#include <pico_types.h>
#include <pico_drv.h>
#include <pico_errors.h>
#include <iocalls.h>
#include <iocalls_linux.h>

class PicoDrvWin : public PicoDrv {
        public:
                            PicoDrvWin    (int devNum, bool readOnly=false);
        virtual             ~PicoDrvWin   ();
        
        // returns true if everything is working, false if not open, etc.
        virtual bool        Ok              ();
        virtual int         LoadFPGA        (const char *fileNameP, const uint8_t *dataP, int size);
        
        // ReadDeviceAbsolute is inherited from PicoDrv
        // WriteDeviceAbsolute is inherited from PicoDrv
        
        virtual int         CreateStream    (int streamNumber);
        virtual void        CloseStream     (int streamHandle);
        virtual int         GetBytesAvailable(int streamHandle, bool isRead=true);
        virtual int         ReadStream      (int streamHandle, void* buf, int size);
        virtual int         WriteStream     (int streamHandle, const void* buf, int size);
        
        virtual int         GetPicoConfig   (PICO_CONFIG *);

        /**********************************************************************************
         * DEPRECATED FUNCTIONS - THESE WILL CONTINUE TO BE SUPPORTED BUT NEW CODE SHOULD *
         *     USE THE FUNCTIONS ABOVE                                                    *
         **********************************************************************************/
        virtual uint32_t    GetDebugFlags   (uint32_t persistent);
        virtual uint32_t    SetDebugFlags   (uint32_t flags);
        virtual int         GetStatistics   (uint32_t* regs, int regcnt);
        virtual int         GetError        ();
        virtual int         TieStreams      (int streamNumA, PicoDrv *picoB, int streamNumB);
        // returns a string describing the driver, its compilation date, etc.
        virtual const char* GetDesc         (char *bufP, int bufSize);
        virtual int         GetPCIPath      (char *bufP, int bufSize);
        virtual int         ReadPLX8111Regs (pico_size_t addr, void* buf, int size=sizeof(uint32_t));
        virtual int         ReadAttributeMemory (int adr, void* bufP, int sizeofBuf);
        virtual int         ReadPort        (int portAdr, void *, int count8=2);
        virtual int         SetExclusiveMode(bool excl);
        virtual int         WritePLX8111Regs(pico_size_t addr, const void* buf, int size=sizeof(uint32_t));
        virtual int         WriteAttributeMemory(int adr, void* bufP, int sizeofBuf);
        virtual int         WritePort       (int portAdr, const void *, int count8=2);
        virtual int         CreateChannel   (int channelNum);
        virtual int         SetPicoAddr     (int fileNo, uint32_t tag);
        virtual int         TieChannels     (int cardA, int channelNumA, int cardB, int channelNumB);
        virtual int         ReadDevice      (pico_size_t addr, void* buf, int size);
        virtual int         WriteDevice     (pico_size_t addr, const void* buf, int size);

        virtual int         DeviceIoControl(struct ixfr *); 
        virtual int         DeviceIoControlError(int erC);

	protected:
		uint64_t	        m_size;
		char	        	m_path[PATH_MAX];
		int          		m_8111File; // only for e16
	    int		        	m_lcsFile;  // only for e16
		int		            m_drvHnd;
        uint32_t            m_debugFlags;
        uint32_t            m_debugLevel;
		int					m_currentDeviceNum;
		int					m_lastErrno;
};

#endif // _PICO_DRV_WIN_H_
/* vim:set ts=4 sts=4 sw=4 et list nowrap: */
