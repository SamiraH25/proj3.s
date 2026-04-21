.data 
input_buffer: .space 1001   
substring:    .space 11     
nan_str:      .asciiz "NaN" 
semi:         .asciiz ";" 
.align 2                    # Makes the next item start on a 4-byte boundary
strint:       .space 4000   # Unsigned integer array space

.text 
.globl main

main: 
     li $v0, 8       
     la $a0, input_buffer  
     li $a1, 1001        
     syscall 
