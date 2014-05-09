/* pico_drv_swsim.h
 * Interface to a software simulation of firmware.
 */

#ifndef _PICO_DRV_SWSIM_H_
#define _PICO_DRV_SWSIM_H_

#include <limits.h>
#include <pico_types.h>
#include <pico_drv.h>
#include <pico_errors.h>
#include <pthread.h>

// how many streams in each direction are we going to support?
// 32 streams to the user module (1-32)
// 2 for ddr3 and picobus (124 and 125 to be consistent with non swsim stuff) 
// 91 unused (0, 34-123)
const int   MAX_SWSIM_STREAMS = 126;
const int   PICOBUS_STREAM    = 125;

// Gets called by RunBitFile
// bitFilePath is the directory where the simulation command files are
int RunSim                  (const char *bitFilePath, PicoDrv **drvpp);

class PicoDrvSWSim : public PicoDrv {
    public:
        
        PicoDrvSWSim                            (const char *path, bool is_fwproj);
        virtual             ~PicoDrvSWSim       ();

        // returns true if everything is working, false if not open, etc.
        
        virtual bool        Ok              ();
        virtual int         LoadFPGA        (const char *fileNameP, const uint8_t *dataP=NULL, int size=0);
        virtual int         ReadDevice      (pico_size_t addr, void* buf, int size);
        virtual int         WriteDevice     (pico_size_t addr, const void* buf, int size);
        virtual const char* GetDesc         (char *bufP, int bufSize);

        static void KillSim         (void);
        int BuildSim          (const char *path);
        int StartSim                ();
        int RunBeforeUserSoftware   (pid_t *pid);
        int RunSim                  (pid_t *pid);

        virtual int  ReadDeviceAbsolute  (pico_size_t addr, void* buf, int size);
        virtual int  WriteDeviceAbsolute (pico_size_t addr, const void* buf, int size);
        virtual int  ReadRam             (uint64_t addr, void* buf, int size, int memID);
        virtual int  WriteRam            (uint64_t addr, const void* buf, int size, int memID);

        virtual int         GetSerial       ();
        virtual int         GetSlot         (char *buf, int bufSize);
        virtual int         GetSysMon       (float* t, float* v, float* i);
        virtual int         CreateChannel   (int streamNumber);
        virtual int         CreateStream    (int streamNumber);
        virtual void        CloseStream     (int streamHandle);
        virtual int         TieStreams      (int streamNumA, PicoDrv *picoDrvB, int streamNumB);
        virtual int         GetBytesAvailable(int streamHandle, bool isRead=true);
        virtual int         ReadStream      (int streamHandle, void* buf, int size);
        virtual int         WriteStream     (int streamHandle, const void* buf, int size);

        virtual int         GetPicoConfig   (PICO_CONFIG *cfg);

    protected:
        char                    m_fwproj_fname[PATH_MAX];
        char                    m_path[PATH_MAX];
        char                    m_parent_path[PATH_MAX];
        uint32_t                m_in_seq[MAX_SWSIM_STREAMS], m_out_seq[MAX_SWSIM_STREAMS];
        char                    m_fname_in_seq[MAX_SWSIM_STREAMS][PATH_MAX],
                                m_fname_in_cmd[MAX_SWSIM_STREAMS][PATH_MAX],
                                m_fname_in_ack[MAX_SWSIM_STREAMS][PATH_MAX],

                                m_fname_out_seq[MAX_SWSIM_STREAMS][PATH_MAX],
                                m_fname_out_cmd[MAX_SWSIM_STREAMS][PATH_MAX],
                                m_fname_out_ack[MAX_SWSIM_STREAMS][PATH_MAX],

								// this file contains the value coming off the output stream
                                m_fname_out_data[MAX_SWSIM_STREAMS][PATH_MAX];

        char                    m_fname_vpi_mem[2][PATH_MAX];
                           
        char                    m_fname_build[PATH_MAX];
        char                    m_fname_build_err[PATH_MAX];

        int                     m_id; 
        pthread_t               m_tie_thread;

        int                     m_8111File; // only for e16
        int                     m_lcsFile;  // only for e16
        int                     m_drvHnd;
        uint32_t            	m_debugFlags;
        uint32_t            	m_debugLevel;
};

#endif // _PICO_DRV_SWSIM_H_
