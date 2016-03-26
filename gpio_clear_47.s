/* 
	David @InfinitelyManic
	Derived from: Raspberry Pi, Assembly Language, Bruce Smith; which is for BCM2835 so some modifications are required
	GPIO PIN access via memory mapping file to GPIO Controller
	This example clears Raspberry Pi 2 GPIO pin 47 or 'ACT' while running Linux Raspbian... 
*/
.bss
.data
	.file:	.ascii	"/dev/mem\000"
	.align 
	
.text
	.global main

	.addr_file:	.word	.file		// pointer to .file 
	.flags:		.word	06010002	// rw . x	// 0x181002
	.gpiobase:	.word	0x3F200000	// confirmed as base address for BCM2836 SOC for Raspberry Pi 2
	.align  
main:
	sub sp, sp, #16
	
	bl open_file 
	str r0, [sp, #0] 			// store file handler to 1st level of stack  
	bl map_file
	str r0, [sp, #8]			// store virt GPIO mem address on stack 
	
.gpio: 
	/*
	.init_output:				// initilize PIN for OUTPUT; may not be neccesary for PIN 47 on Raspberry Pi 2
	ldr r3, [sp, #8]			// load virt GPIO base 
	add r3, r3, #16				// point to GPSEL4 
	ldr r2, [r3]				// get contents of GPSEL4
	orr r2, r2, #0b111<<21			// set 3 bits for PIN 47; 0xe00000
	str r2, [r3]				// store set bits at GPSEL4 
	*/

	.clear:
	ldr r3, [sp, #8]			// load virt GPIO base 
	add r3, r3, #44				// GPCLR1
	ldr r2, [r3] 				// get content of GPSET1
	orr r2, #1<<15				// s/u PIN 47
	str r2,[r3]				// set PIN 47 @ GPSET1 

	bl close_file 

	add sp, sp, #16

exit:
	mov r7, #1
	svc 0


open_file:
	push {r1-r3, lr}
	ldr r0, .addr_file			// get /dev/mem file for virtual file addr 
	ldr r1, .flags				// set flag permissions		// rw - r 
	bl open 				// calls open; returns file handle in r0
	pop {r1-r3, pc}


map_file:
	push {r1-r3, lr}
	str r0, [sp, #0]			// store returned file handle to 1st level of stack
	ldr r3, [sp, #0]			// copy file handle to r3 
	// parameters for mmap			// nmap will map files or devices into memory 
	str r3, [sp, #0]			// copy file handle to 1st level of stack for mmap
	ldr r3,.gpiobase			// GPIO base address 
	str r3, [sp, #4]			// store GPIO base to 2nd level of stack	for mmap
	mov r0, #0				// null address - let the kernel choose the address 
	mov r1, #4096				// page size
	mov r2, #3				// desired memory protection type ???
	mov r3, #1				// stdout 
	bl mmap					// call mmap; returns kernel mapped addr in r0
	pop {r1-r3, pc}


close_file:	// params for file close 	
	push {r1-r3, lr}
	ldr r0, [sp, #0]			// get file handle 
	bl close
	pop {r1-r3, pc}
