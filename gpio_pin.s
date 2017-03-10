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
        while :; do sudo ./led_matrix ; sleep 1; done

        Last Revision Date: 03/10/2017
*/
.bss
.data
        .file:  .ascii  "/dev/mem\000"
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

init_output:                                    // init for OUTPUT; may not be neccesary for PIN 47 on Raspberry Pi 2
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #0x10                       // offset to GPFSEL4
        ldr r2, [r3]                            // get contents of GPFSEL4
        orr r2, r2, #0b111<<21                  // set 3 bits re FSEL47 output
        str r2, [r3]                            // store set bits at GPFSEL4
        bx lr

set_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #0x20                       // GPSET1
        ldr r2, [r3]                            // get content of GPSET1
        orr r2, r2, #1<<15                              // set PIN 47
        str r2,[r3]                             // set PIN 47 @ GPSET1
        bx lr

clear_pin:
        ldr r3, [sp, #8]                        // virt GPIO base
        add r3, r3, #0x2c                       // GPCLR1
        ldr r2, [r3]                            // get content of GPCLR1
        orr r2, r2, #1<<15                      // set PIN 47
        str r2,[r3]                             // set PIN 47 @ GPCLR1
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
