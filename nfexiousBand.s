*                                                                                                                                                                      
        /u/InfexiousBand                                                                                                                                                
        https://www.reddit.com/r/asm/comments/61hfr3/how_do_i_compare_two_values/                                                                                       
        http://pastebin.com/CGEBUzJx                                                                                                                                    
        modified by David @InfinitelyManic                                                                                                                              
*/                                                                                                                                                                      
.section .bss                                                                                                                                                           
.section .data                                                                                                                                                          
// Declare the strings and data needed                                                                                                                                  
        strInputPrompt:         .asciz "Input the number: \n"                                                                                                           
                                                                                                                                                                        
        numOutputGreater:       .asciz "The input number is greater than or equal to 100.\n"                                                                            
        numOutputLesser:        .asciz "The input number is less than 100.\n"                                                                                           
        numInputPattern:        .asciz "%d"                                                                                                                             
//character vars---------------------------------                                                                                                                       
        strInputPromptChar:     .asciz "Input the character: \n"                                                                                                        
                                                                                                                                                                        
        strOutputLowercase:     .asciz "Lowercase letter entered.\n"                                                                                                    
        strOutputUppercase:     .asciz "Uppercase letter entered.\n"                                                                                                    
        strOutputWeird:         .asciz "Special character entered.\n"                                                                                                   
        numInputPatternChar:    .asciz "%s"                                                                                                                             
//-----------------------------------------                                                                                                                             
.align 4                                                                                                                                                                
.section .text                                                                                                                                                          
        .global main // Have to use main because of C library uses.                                                                                                     
main:                                                                                                                                                                   
                                                                                                                                                                        
prompt:                                                                                                                                                                 
        // Ask the user to enter a number.                                                                                                                              
        ldr r0, =strInputPrompt         // Put the address of my string into the first parameter                                                                        
        bl _print                       // Call the C print to display input prompt.                                                                                    
                                                                                                                                                                        
get_input:                                                                                                                                                              
        ldr r0, =numInputPattern        // Setup to read in one number.                                                                                                 
        bl _scan                                                                                                                                                        
        mov r1, r0                                                                                                                                                      
                                                                                                                                                                        
// print the input out as a number.                                                                                                                                     
checkNumber:                                                                                                                                                            
        cmp r1, #100                                                                                                                                                    
        bge printGreater                                                                                                                                                
                              
printLess:                                                                                                                                                              
//  r1 is already loaded with the number to print.                                                                                                                      
        ldr r0, =numOutputLesser                                                                                                                                        
        bl _print                                                                                                                                                       
        b promptStr                                                                                                                                                     
                                                                                                                                                                        
printGreater:                                                                                                                                                           
        ldr r0, =numOutputGreater                                                                                                                                       
        bl _print                                                                                                                                                       
                                                                                                                                                                        
//now for the character ----------------------------------------                                                                                                        
promptStr:                                                                                                                                                              
// Ask the user to enter a character.                                                                                                                                   
        ldr r0, =strInputPromptChar     // Put the address of my string into the first parameter                                                                        
        bl _print                                                                                                                                                       
                                                                                                                                                                        
get_inputStr:                                                                                                                                                           
// Set up r0 with the address of input pattern                                                                                                                          
        ldr r0, =numInputPatternChar    // Setup to read in one number.                                                                                                 
        bl _scan                                                                                                                                                        
        mov r1, r0                                                                                                                                                      
                                                                                                                                                                        
// print the input out as a number.                                                                                                                                     
checkChar:                                                                                                                                                              
        cmp r1, #123                                                                                                                                                    
        bge printWeird                                                                                                                                                  
        cmp r1, #97                                                                                                                                                     
        bge printLowercase                                                                                                                                              
        cmp r1, #91                                                                                                                                                     
        bge printWeird                                                                                                                                                  
        cmp r1, #65                                                                                                                                                     
        bge printUppercase                                                                                                                                              
        // b printWeird                               
        tWeird:                                                                                                                                                             
//  r1 is already loaded with the number to print.                                                                                                                      
        ldr r0, =strOutputWeird                                                                                                                                         
        bl _print                                                                                                                                                       
        b myexit                                                                                                                                                        
                                                                                                                                                                        
printUppercase:                                                                                                                                                         
//  r1 is already loaded with the number to print.                                                                                                                      
        ldr r0, =strOutputUppercase                                                                                                                                     
        bl _print                                                                                                                                                       
        b myexit                                                                                                                                                        
                                                                                                                                                                        
printLowercase:                                                                                                                                                         
//  r1 is already loaded with the number to print.                                                                                                                      
        ldr r0, =strOutputLowercase                                                                                                                                     
        bl _print                                                                                                                                                       
                                                                                                                                                                        
//End of my code. Force the exit and return control to OS                                                                                                               
myexit:                                                                                                                                                                 
        mov r7, #0x01 //SVC call to exit                                                                                                                                
        svc 0         //Make the system call.                                                                                                                           
                                                                                                                                                                        
_print:                                                                                                                                                                 
        push {lr}                                                                                                                                                       
        bl printf                                                                                                                                                       
        pop {pc}                                                                                                                                                        
                                                                                                                                                                        
_scan:                                                                                                                                                                  
        push {lr}                                                                                                                                                       
        sub sp, sp, #8                                                                                                                                                  
        mov r1, sp                                                                                                                                                      
        bl scanf                                                                                                                                                        
        ldr r0, [sp]                                                                                                                                                    
        add sp, sp, #8                                                                                                                                                  
        pop {pc}                                                                                                                                                        
                                                                                                                                                                        
//end of code.                                                                                                                                                          
.end          
