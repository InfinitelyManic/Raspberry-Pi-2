/*
        David @InfinitelyManic
        Derived from: Raspberry Pi, Assembly Language, Bruce Smith; but is for BCM2835 so some modifications are required
        GPIO PIN access via memory mapping file to GPIO controller
        This example sets Raspberry Pi 2 GPIO pin 47 or 'ACT' while running Linux Raspbian...

        $ uname -a
        Linux raspberrypi 4.4.50-v7+ #970 SMP Mon Feb 20 19:18:29 GMT 2017 armv7l GNU/Linux

        $ lshw
        ...
        product: Raspberry Pi 2 Model B Rev 1.1

        compile:
        $ gcc -g led_matrix.s -o led_matrix

        example run:
        while :; do sudo ./led_matrix ; done

        Last Revision Date: 03/10/2017
*/
.bss
.data
        .file:  .ascii  "/dev/mem\000"

        .equ    GPFSEL0,0x0
        .equ    GPFSEL1,0x4
        .equ    GPFSEL2,0x8
        .equ    GPFSEL3,0xc
        .equ    GPFSEL4,0x10
        .equ    GPFSEL5,0x14

        .equ    FSEL9,27
        .equ    FSEL8,24
        .equ    FSEL7,21
        .equ    FSEL6,18
        .equ    FSEL5,15
        .equ    FSEL4,12
        .equ    FSEL3,9
        .equ    FSEL2,6
        .equ    FSEL1,3
        .equ    FSEL0,0

        .equ    FSEL19,27
        .equ    FSEL18,24
        .equ    FSEL17,21
        .equ    FSEL16,18
        .equ    FSEL15,15
        .equ    FSEL14,12
                .equ    FSEL14,12
        .equ    FSEL13,9
        .equ    FSEL12,6
        .equ    FSEL11,3
        .equ    FSEL10,0

        .equ    FSEL29,27
        .equ    FSEL28,24
        .equ    FSEL27,21
        .equ    FSEL26,18
        .equ    FSEL25,15
        .equ    FSEL24,12
        .equ    FSEL23,9
        .equ    FSEL21,3
        .equ    FSEL20,0

        .equ    FSEL39,27
        .equ    FSEL38,24
        .equ    FSEL37,21
        .equ    FSEL36,18
        .equ    FSEL35,15
        .equ    FSEL34,12
        .equ    FSEL33,9
        .equ    FSEL31,3
        .equ    FSEL30,0

        .equ    FSEL49,27
        .equ    FSEL48,24
        .equ    FSEL47,21
        .equ    FSEL46,18
        .equ    FSEL45,15
        .equ    FSEL44,12
        .equ    FSEL43,9
        .equ    FSEL42,6
        .equ    FSEL41,3
        .equ    FSEL40,0

        .equ    FSEL53,9
        .equ    FSEL52,6
        .equ    FSEL51,3
        .equ    FSEL50,0

        .equ    GPSET0,0x1c
        .equ    GPSET1,0x20

        .equ    GPCLR0,0x28
        .equ    GPCLR1,0x2c

                                                                                                                                                                           49,2-9        Top
        .equ    _0,0
        .equ    _1,1
        .equ    _2,2
        .equ    _3,3
        .equ    _4,4
        .equ    _5,5
        .equ    _6,6
        .equ    _7,7
        .equ    _8,8
        .equ    _9,9

        .equ    _10,10
        .equ    _11,11
        .equ    _12,12
        .equ    _13,13
        .equ    _14,14
        .equ    _15,15
        .equ    _16,16
        .equ    _17,17
        .equ    _18,18
        .equ    _19,19

        .equ    _20,20
        .equ    _21,20
        .equ    _22,22
        .equ    _23,23
        .equ    _24,24
        .equ    _25,25
        .equ    _26,26
        .equ    _27,27
        .equ    _28,28
        .equ    _29,29

        .equ    _30,30
        .equ    _31,31

        .equ    _32,0
        .equ    _33,1
        .equ    _34,2
        .equ    _35,3
        .equ    _36,4
        .equ    _37,5
        .equ    _38,6
        .equ    _39,7
        .equ    _40,8
        .equ    _41,9
        .equ    _42,10
        .equ    _43,11
        .equ    _43,11
        .equ    _44,12
        .equ    _45,13
        .equ    _46,14
        .equ    _47,15
        .equ    _48,16
        .equ    _49,17
        .equ    _49,18
        .equ    _49,19
        .equ    _49,20
        .equ    _49,21


        .align
.text
        .global main

        .addr_file:     .word   .file           // pointer to .file
        .flags:         .word   06010002        // rw . x       // 0x181002
        .gpiobase:      .word   0x3F200000      // confirmed as base address for BCM2836 SOC for Raspberry Pi 2
        .align
main:
        nop
        sub sp, sp, #16

        bl open_file
        str r0, [sp, #0]                        // store file handler on stack
        bl map_file
        str r0, [sp, #8]                        // store virt GPIO mem address on stack

        bl init_output

        bl clear_pin

        bl _delay

        bl set_pin

        bl _delay

        bl clear_pin

        bl close_file

        add sp, sp, #16
exit:
        mov r7, #1
        svc 0

_delay:
        ldr r9,=0xffffff
        1:
        subs r9, #1
        bpl 1b
        bx lr

init_output:                                    // init for OUTPUT //
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPFSEL1                    // offset to GPFSELn = int(PIN#/10)= GPFSELn
        ldr r2, [r3]                            // get contents of GPFSELn
        orr r2, r2, #(1 << FSEL18)              // set 3 bits re FSELn output
        str r2, [r3]                            // store set bits at GPFSELn
        bx lr

set_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPSET0                     // offset to GPSETn = int(PIN#/31)=GPSETn
        ldr r2, [r3]                            // get content of GPSETn
        orr r2, r2, #(1 << _18)                 // friendly select FSELn
        str r2,[r3]                             //
        bx lr

clear_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #GPCLR0                     // offset to GPCLRn= int(PIN#/31)=GPCLRn=
        ldr r2, [r3]                            // get content of GGPCLRn
        orr r2, r2, #(1 << _18)                 // FSELn
        str r2,[r3]                             // friendly select FSELn
        bx lr

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

.align
.end
                                                               
