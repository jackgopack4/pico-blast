/* PicoBus128_HelloWorld.cpp
 *
 * This program shows how to use the PicoBus128 interface to firmware, using the PicoBus128_HelloWorld firmware module.
 *
 * Usage: "helloworld [<bitFileName>]"
 *   e.g. "./helloworld ../firmware/M501_PicoBus128_HelloWorld.bit"
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#include <picodrv.h>
#include <pico_errors.h>

int main(int argc, char* argv[]) {
    int         i, err;
    uint32_t    buf[] = {0x76543210, 0xfedcba98, 0x76543210, 0xfedcba98}, buf2[4];
    char        ibuf[1024];
    PicoDrv     *pico;
    const char* bitFileName = "M501_PicoBus128_HelloWorld.bit";
    
    // specify the .bit file name on the command line
    if (argc < 2) {
        fprintf(stderr, "Please specify the .bit file on the command line.\n"
                        "For example: helloworld ../firmware/M501_PicoBus128_HelloWorld.bit\n");
        exit(1);
    }
    bitFileName = argv[1];
    
    // The RunBitFile function will locate a Pico card that can run the given bit file, and is not already
    //   opened in exclusive-access mode by another program. It requests exclusive access to the Pico card
    //   so no other programs will try to reuse the card and interfere with us.
    printf("Loading FPGA with '%s' ...\n", bitFileName);
    err = RunBitFile(bitFileName, &pico);
    if (err < 0) {
        // We use the PicoErrors_FullError function to decipher error codes from RunBitFile.
        // This is more informative than just printing the numeric code, since it can report the name of a
        //   file that wasn't found, for example.
        fprintf(stderr, "RunBitFile error: %s\n", PicoErrors_FullError(err, ibuf, sizeof(ibuf)));
        exit(1);
    }

    // now we write to each of the registers we created in the firmware. each will respond differently to a write,
    //   and we'll have to read back from them to see what each one did.
    /**********************
     * add new writes to pico bus based on database
     * make sure to declare those writes in the verilog module
     */
    if((err = pico->WriteDeviceAbsolute(0, buf, 16)) < 0) {
        fprintf(stderr, "Error Writing: %d\n", err);
        exit(1);
    }
    if((err = pico->WriteDeviceAbsolute(0x10, buf, 16)) < 0) {
        fprintf(stderr, "Error Writing: %d\n", err);
        exit(1);
    }
    if((err = pico->WriteDeviceAbsolute(0x20, buf, 16)) < 0) {
        fprintf(stderr, "Error Writing: %d\n", err);
        exit(1);
    }

    printf("Wrote: 0x%08x%08x%08x%08x to each of three registers (@ addresses 0, 0x10, 0x20)\n", buf[3], buf[2], buf[1], buf[0]);

    // read the register at address 0.
    // this register should have inverted the bits of the 128-bit word that we wrote to it.
    if((err = pico->ReadDeviceAbsolute(0, buf2, 16)) < 0) {
        fprintf(stderr, "Error Reading: %d\n", err);
        exit(1);
    }

    printf("Read 0x0:  0x%08x%08x%08x%08x\n", buf2[3], buf2[2], buf2[1], buf2[0]);
    if (buf2[3] != 0x01234567 ||
        buf2[2] != 0x89abcdef ||
        buf2[1] != 0x01234567 ||
        buf2[0] != 0x89abcdef){
        printf("Error: unexpected values received when reading register 0x0\n");
        exit(1);
    }
    
    // read the register at address 0x30.
    // this register keeps a count of the total number of writes to any of the registers.
    if((err = pico->ReadDeviceAbsolute(0x30, buf2, 16)) < 0) {
        fprintf(stderr, "Error Reading: %d\n", err);
        exit(1);
    }

    printf("Read 0x30:  0x%08x%08x%08x%08x\n", buf2[3], buf2[2], buf2[1], buf2[0]);
    if (buf2[0] != 0x3){
        printf("Error: unexpected values received when reading register 0x0\n");
    }else{
        printf("All tests successful!\n");
    }
    return 0;
} //main...