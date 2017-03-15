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
        gcc -g gpio_pin_auto_init_mmap.s -o gpio_pin_auto_init_mmap                                                                                                     
                                                                                                                                                                        
        Last Revision Date: 03/14/2017                                                                                                                                  
*/                                                                                                                                                                      
.bss                                                                                                                                                                    
        gpio_pin_init_array:    .word 5                                                                                                                                 
.data                                                                                                                                                                   
        fmt0:   .string "Please select PIN#!\n"                                                                                                                         
      //  fmt1:   .string "You selected PIN# %d\n"                                                                                                                        
        scan0:  .string  "%d"                                                                                                                                           
        .file:  .ascii          "/dev/mem\000"                                                                                                                          
        .align                                                                                                                                                          
.text                                                                                                                                                                   
        .addr_file:     .word   .file           // pointer to .file                                                                                                     
        .flags:         .word   06010002        // rw . x       // 0x181002                                                                                             
        .gpiobase:      .word   0x3F200000      // confirmed as base address for BCM2836 SOC for Raspberry Pi 2                                                         
                                                                                                                                                                        
        // macro                                                                                                                                                        
        .macro  gpio_pin_matrix PIN                                                                                                                                     
        .gpio_pin_matrix\@:                                                                                                                                             
                ldr r9,=gpio_pin_init_array                                                                                                                             
                mov r12, \PIN           //                                                                                                                              
                // *************************************************
                
                   .calcGPFSELn\@:         // GPFSELn=int(PIN#/10) << 2                                                                                                    
                intDiv r12, #10         // int(PIN/10)                                                                                                                  
                lsl r0, #2              // int(PIN/10) << 2                                                                                                             
                str r0, [r9, #0]        // element 0                                                                                                                    
                                                                                                                                                                        
                .calcFSELn\@:           // FSELn=3(PIN# mod 10)                                                                                                         
                mod r12 ,#10            // PIN mod 10                                                                                                                   
                lsl r1, r0, #1          // x << 1                                                                                                                       
                add r0, r1, r0          // (x << 1) + x == 3x                                                                                                           
                str r0, [r9,#4]         // element 1                                                                                                                    
                                                                                                                                                                        
                .calcGPSET\@:           // GPSETn=int(PIN#/31)                                                                                                          
                intDiv r12, #31         // int(PIN/31)                                                                                                                  
                cmp r0, #0              // conditional offset addr                                                                                                      
                moveq r0, #0x1c                                                                                                                                         
                movne r0, #0x20                                                                                                                                         
                str r0, [r9, #8]        // element 2                                                                                                                    
                                                                                                                                                                        
                .calcGPCLRn\@:          // GPCLRn=int(PIN#/31)                                                                                                          
                intDiv r12, #31         // int(PIN/31)                                                                                                                  
                cmp r0, #0              // conditional offset addr                                                                                                      
                moveq r0, #0x28                                                                                                                                         
                movne r0, #0x2c                                                                                                                                         
                str r0, [r9, #12]       // element 3                                                                                                                    
                                                                                                                                                                        
                .calcGPBIT\@:           // GPBIT=PIN# mod 32 ; bits of GPSET & GPCLR                                                                                    
                mov r1, #1                                                                                                                                              
                mod r12, #32            // GPBITS mod 32                                                                                                                
                str r0, [r9, #16]       // element 4                                                                                                                    
        .endm     
                .global main                                                                                                                                                    
        .include "mymac.s"              // my personal macros - you will need your own macros or functions for intDiv and mod                                           
                                                                                                                                                                        
        .align                                                                                                                                                          
                                                                                                                                                                        
// ******************** MAIN ********************************************************************                                                                       
main:                                                                                                                                                                   
        nop                                                                                                                                                             
        sub sp, sp, #16                                                                                                                                                 
                                                                                                                                                                        
1:                                                                                                                                                                      
        bl open_file                                                                                                                                                    
        str r0, [sp, #0]                        // store file handler on stack                                                                                          
        bl map_file                                                                                                                                                     
        str r0, [sp, #8]                        // store virt GPIO mem address on stack                                                                                 
                                                                                                                                                                        
        bl _write0                              // Ask user to select PIN #                                                                                             
        bl _scan0                               // get user input                                                                                                       
        cmp r0, #53                             // max pin = 53                                                                                                         
        bgt 1b                                                                                                                                                          
                                                                                                                                                                        
.stop0:                                                                                                                                                                 
        gpio_pin_matrix r0                      // pre gpio init calculations                                                                                           
.stop1:                                                                                                                                                                 
        bl init_output                          // init GPIO for output                                                                                                 
.stop2:                                                                                                                                                                 
        bl set_pin                              // set PIN                                                                                                              
        bl _delay                               // some arbitrary delay                                                                                                 
        bl clear_pin                            // clear PIN                                                                                                            
        bl close_file                           // close file                                                                                                           
                                                                                                                                                                        
        add sp, sp, #16                                                                                                                                                 
                                                                                                                                                                        
exit:                                                                                                                                                                   
        mov r7, #1                                                                                                                                                      
        svc 0   
        _delay:                                                                                                                                                                 
        ldr r9,=0x3fffffff                                                                                                                                              
        1:                                                                                                                                                              
        subs r9, #1                                                                                                                                                     
        bpl 1b                                                                                                                                                          
        bx lr                                                                                                                                                           
// ****************************GPIO REGISTER AND PIN PARAMS ***********************************                                                                         
init_output:                                    // init for OUTPUT //                                                                                                   
        ldr r3, [sp, #8]                        // virt GPIO base                                                                                                       
        ldr r9,=gpio_pin_init_array                                                                                                                                     
                                                                                                                                                                        
        ldr r12, [r9, #0]                       // get GPSELn offset                                                                                                    
        add r3, r3, r12                         // offset to GPFSELn=int(PIN#/10)                                                                                       
        ldr r2, [r3]                            // get contents of GPFSELn                                                                                              
                                                                                                                                                                        
        ldr r12, [r9, #4]                       // get FSELn value                                                                                                      
        mov r0, #0b001                                                                                                                                                  
        lsl r12, r0, r12                        // 0b111 << FSELn                                                                                                       
        orr r2, r2, r12                         // friendly set 3 bits ;FSELn=3(PIN# mod 10)                                                                            
        str r2, [r3]                            //                                                                                                                      
        bx lr                                                                                                                                                           
                                                                                                                                                                        
set_pin:                                                                                                                                                                
        ldr r3, [sp, #8]                        // virt GPIO base                                                                                                       
        ldr r9,=gpio_pin_init_array                                                                                                                                     
                                                                                                                                                                        
        ldr r12, [r9, #8]                       // get GPSET offset                                                                                                     
        add r3, r3, r12                         // offset to GPSETn=int(PIN#/31)                                                                                        
        ldr r2, [r3]                            // get content of GPSETn                                                                                                
        ldr r12, [r9, #16]                      // get GPBIT                                                                                                            
        mov r0, #1                                                                                                                                                      
        lsl r12, r0, r12                        // (1 << GPBIT)                                                                                                         
        orr r2, r2, r12                         // friendly set 3 bits ;FSELn=3(PIN# mod 10)                                                                            
        str r2,[r3]                             //                                                                                                                      
        bx lr                                                                                                                                                           
                        
clear_pin:                                                                                                                                                              
        ldr r3, [sp, #8]                        // virt GPIO base                                                                                                       
        ldr r9,=gpio_pin_init_array                                                                                                                                     
                                                                                                                                                                        
        ldr r12, [r9, #12]                                                                                                                                              
        add r3, r3, r12                         // offset to GPCLRn=int(PIN#/31)                                                                                        
        ldr r2, [r3]                            // get content of GGPCLRn                                                                                               
        ldr r12, [r9, #16]                      // get GPBIT                                                                                                            
        mov r0, #1                                                                                                                                                      
        lsl r12, r0, r12                        // (1 << GPBIT)                                                                                                         
        orr r2, r2, r12                         // friendly PIN select; _=(PIN# mod 32)                                                                                 
        str r2,[r3]                             //                                                                                                                      
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
                                                                                          
