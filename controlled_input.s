/*
        David @InfinitelyManic
        Based on the code dev by Kevin M. Thomas @ https://github.com/kevinmthomasse/controlled_input/blob/master/controlled_input.s
        Start Date: 09/12/2016
        compiled on:
        Linux raspberrypi 4.4.11-v7+ #888 SMP Mon May 23 20:10:33 BST 2016 armv7l GNU/Linux
        as controlled_input.s -o controlled_input.o && ld controlled_input.o -o controlled_input
        Last Revision: 09/14/2016 _002
*/

.bss
        buffer:         .zero 4                 // fill n bytes w/ zeros
        .align
//      flush_buffer:   .byte   0               // not sure if we need this
.data
        prompt:         .asciz  "Enter ONLY 4 numbers: \n"
        .equ            len.prompt,.-prompt

        result: .asciz  " is your result!\n"
        .equ            len.result,.-result
//      lr:     .asciz  "\n"                    // not sure if we need this
        .align
.text
        .global _start
_start:
        nop
        bl write_prompt

.read_buffer:                   // label for looping when input values are not between ASCII 0 and 9
        bl read_buffer

//      cmp r11, #(4 * 5)
//      bge .read_buffer
//      movl $4, %eax
//      movl $buffer, %ebx
//      test_for_int:
//      cmpb $0x30, (%ebx)
//      jb read_buffer
//      cmpb $0x39, (%ebx)
//      ja read_buffer
//      inc %ebx
//      dec %eax
//      jnz test_for_int

        // we only want ASCII number between 0 and 9 so reject anything else then redo read...
        ldr r9,=buffer
        eor r10, r10                    // counter
        1:
                ldrb r11, [r9,r10]      // load one byte from buffer array at element n
                cmp r11, #0x30
                blt .read_buffer        // is it < ASCII value for 0; if so then get more input

                cmp r11, #0x39
                bgt .read_buffer        // is it > ASCII value for 9

        add r10, #1             // increment counter n
        cmp r10, #3             // we only want to loop n times
        ble 1b

        //bl close_fd
        bl write_int_result     // followed by the four (4) bytes.
        bl flush
        bl write_result         // write the phrase

exit:
        eor r0, r0
        mov r7, #1
        svc 0

write_prompt:
//      mov 4, %eax
//      mov 1, %ebx
//      mov prompt, %ecx
//      mov 24, %edx
//      int $0x80
        push {r1-r7,lr}
        mov r7, #4              // syscall write
        mov r0, #1              // fd dtdout
        ldr r1,=prompt
        mov r2, #len.prompt
        svc #0
        pop {r1-r7,pc}
read_buffer:
//      movl $3, %eax
//      movl $0, %ebx
//      movl $buffer, %ecx
//      movl $4, %edx
//      int $0x80
        push {r1-r9,lr}
        mov r7, #3              // syscall read
        mov r0, #0              // fd stdin
        ldr r1,=buffer
        mov r2, #4              // arbitrary length
        svc #0
        pop {r1-r9,pc}


write_result:
//      movl $4, %eax
//      movl $1, %ebx
//      movl $result, %ecx
//      movl $9, %edx
//      int $0x80
        push {r1-r7,lr}
        mov r7, #4              // syscall write
        mov r0, #1              // fd stdout
        ldr r1,=result
        mov r2, #len.result
        svc #0
        pop {r1-r7,pc}
        write_int_result:
//      movl $4, %eax
//      movl $1, %ebx
//      movl $buffer, %ecx
//      movl $4, %edx
//      int $0x80

//      movl $4, %eax
//      movl $1, %ebx
//      movl $lr, %ecx
//      movl $2, %edx
//      int $0x80
        push {r1-r7,lr}
        mov r7, #4              // syscall write
        mov r0, #1              // fd stdout
        ldr r1,=buffer
        mov r2, #4              // bytes to write
        svc #0
        pop {r1-r7,pc}

flush:
//      movl $3, %eax
//      movl $0, %ebx
//      movl $flush_buffer, %ecx
//      movl $1, %edx
//      int $0x80
//      cmpb $0xa, -0x1(%ecx, %edx, 1)
//      jne flush
        push {r1-r7,lr}
        mov r7, #3              // syscall read
        mov r0, #1              // fd stdout
        ldr r1,=buffer
        movw r2, #0xffff            // arbitrary
        movt r2, #0x7fff            // arbitrary
        svc #0
        pop {r1-r7,pc}
