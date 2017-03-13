/*
        David @InfinitelyManic
        Derived from: Raspberry Pi, Assembly Language, Bruce Smith; but is for BCM2835 so some modifications are required
        GPIO PIN access via memory mapping file to GPIO controller
        Documentation: https://www.raspberrypi.org/wp-content/uploads/2012/02/BCM2835-ARM-Peripherals.pdf

       
       $ uname -a
        Linux raspberrypi 4.4.50-v7+ #970 SMP Mon Feb 20 19:18:29 GMT 2017 armv7l GNU/Linux

        $ lshw
        ...
        product: Raspberry Pi 2 Model B Rev 1.1

        compile:
        $ gcc -g gpio_init_test_via_mmap.s -o gpio_init_test_via_mmap

        Last Revision Date: 03/13/2017
*/
.bss
.data
        // TO DO LATER....
        fmt0:   .string "Please selet the PIN#!\n"
        fmt1:   .string "You selected PIN# %d\n"
        scan0:  .string  "%d"
        
        .file:  .ascii          "/dev/mem\000"
        .align
.text
        .global main
        .include "rpi_2_b_header.h"             // home made headers based on BCM2835 doc

        .addr_file:     .word   .file           // pointer to .file
        .flags:         .word   06010002        // rw . x       // 0x181002
        .gpiobase:      .word   0x3F200000      // confirmed as base address for BCM2836 SOC for Raspberry Pi 2
        .align
main:
        nop
        sub sp, sp, #16                                                                                                                                                                      
/*      TO DO LATER...                                                                                                                                                                                     // Ask user to select PIN #                                                                                                                                                          1:
        bl _write0
        bl _scan0
        cmp r0, #53                             // max pins = 53
        bgt 1b
        bl _write1
*/

        bl open_file
        str r0, [sp, #0]                        // store file handler on stack
        bl map_file
        str r0, [sp, #8]                        // store virt GPIO mem address on stack

        bl init_output                          // init GPIO for output
        bl set_pin                              // set PIN
        bl _delay                               // some arbitrary delay
        bl clear_pin                            // clear PIN
        bl close_file                           // close file

        add sp, sp, #16

exit:
        mov r7, #1
        svc 0

_delay:
        ldr r9,=0x0ffffff
        1:
        subs r9, #1
        bpl 1b
        bx lr

// ****************************GPIO REGISTER AND PIN PARAMS ***********************************
init_output:                                    // init for OUTPUT //
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPFSEL2                    // offset to GPFSELn = int(PIN#/10)= GPFSELn
        ldr r2, [r3]                            // get contents of GPFSELn
        orr r2, r2, #(1 << FSEL23)              // friendly set 3 bits re FSELn output
        str r2, [r3]                            // store set bits at GPFSELn
        bx lr

set_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPSET0                     // offset to GPSETn = int(PIN#/31)=GPSETn
        ldr r2, [r3]                            // get content of GPSETn
        orr r2, r2, #(1 << _23)                 // friendly PIN select
        str r2,[r3]                             //
        bx lr

clear_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPCLR0                     // offset to GPCLRn= int(PIN#/31)=GPCLRn=
        ldr r2, [r3]                            // get content of GGPCLRn
        orr r2, r2, #(1 << _23)                 // FSELn
        str r2,[r3]                             // friendly PIN select
        bx lr
// ********************************************************************************************

open_file:
        push {r1-r3, lr}
        ldr r0, .addr_file                      // get /dev/mem file for virtual file addr
        ldr r1, .flags                          // set flag permissions         // rw - r
        bl open                                 // calls open; returns file handle in r0
        pop {r1-r3, pc}


map_file:
        push {r1-r3, lr}
        str r0, [sp, #0]                        // store returned file handle to 4th level of stack
        ldr r3, [sp, #0]                        // copy file handle to r3
        // parameters for mmap                  // nmap will map files or devices into memory
        str r3, [sp, #0]                        // copy file handle to 1st level of stack for mmap
        ldr r3,.gpiobase                        // GPIO base address
        str r3, [sp, #4]                        // store GPIO base to 2nd level of stack        for mmap
        mov r0, #0                              // null address - let the kernel choose the address
        mov r1, #4096                           // page size
        mov r2, #3                              // desired memory protection type ???
        mov r3, #1                              // stdout
        bl mmap                                 // call mmap; returns kernel mapped addr in r0
        pop {r1-r3, pc}


close_file:     // params for file close
        push {r1-r3, lr}
        ldr r0, [sp, #0]                        // get file handle
        bl close
        pop {r1-r3, pc}

_write0:
        push {r1-r3,lr}
        ldr r0,=fmt0
        bl printf
        pop {r1-r3,pc}

_scan0:
        push {r1-r3,lr}
        ldr r0,=scan0
        mov r1, sp
        bl scanf
        ldr r0,[sp]             // store entry
        pop {r1-r3,pc}
_write1:
        push {r1-r3,lr}
        mov r1, r0              // output saved value
        ldr r0,=fmt1
        bl printf
        pop {r1-r3,pc}

.align
.end
                                        
