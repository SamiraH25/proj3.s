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

     addi $sp, $sp, -8      # Allocate stack for 2 args
     la $t0, input_buffer
     sw $t0, 4($sp)         # Push string address
     la $t1, strint
     sw $t1, 0($sp)         # Push array address

     jal process_string     # Call subprogram

     
     lw $s0, 0($sp)         # $s0 = Number of substrings
     addi $sp, $sp, 8       # Restore stack pointer

     
     li $s1, 0              # Loop index
     la $s2, strint         # Array pointer
     li $s3, 0              # Semicolon flag

print_loop:
     beq $s1, $s0, exit_progam # Stop when all substrings processed
     
     
     beq $s3, $zero, skip_semi
     li $v0, 4
     la $a0, semi
     syscall

skip_semi:
     li $s3, 1              # Enable semicolons after first print

     lw $t7, 0($s2)         # Load current integer from array
     
     li $t8, -1
     beq $t7, $t8, print_nan

     li $v0, 1              # Print Integer
     move $a0, $t7
     syscall
     j next_val
