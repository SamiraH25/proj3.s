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

print_nan:
     li $v0, 4              # Print "NaN"
     la $a0, nan_str
     syscall

next_val:
     addi $s1, $s1, 1       # Increment index
     addi $s2, $s2, 4       # Increment array pointer 
     j print_loop

exit_progam:
     li $v0, 10             # Exit syscall
     syscall 

process_string:
    lw $t0, 4($sp)          # Get input address from stack
    lw $t1, 0($sp)          # Get array address from stack
    li $s4, 0               # Counter for substrings processed

process_chunk_loop:
    lb $t4, 0($t0)          # Check for end of input
    beq $t4, $zero, end_process
    li $t5, 10              # Newline check
    beq $t4, $t5, end_process

    li $t2, 0               # Reset chunk counter
    la $t3, substring       # Substring buffer

fill_sub:
    lb $t4, 0($t0)
    beq $t4, $zero, pad_sub
    li $t5, 10
    beq $t4, $t5, pad_sub
    sb $t4, 0($t3)

    addi $t0, $t0, 1
    addi $t3, $t3, 1
    addi $t2, $t2, 1
    blt $t2, 10, fill_sub
    j call_get_int

pad_sub:
    li $t5, 32              # Pad with space
    sb $t5, 0($t3)
    addi $t3, $t3, 1
    addi $t2, $t2, 1
    blt $t2, 10, pad_sub

call_get_int:
    sb $zero, 0($t3)        # Null terminate substring
    
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $t0, 4($sp)
    sw $t1, 0($sp)
    
    la $a0, substring
    jal get_substr_int      # Call calculation subroutine
    
    lw $t1, 0($sp)          # Restore array pointer
    sw $v0, 0($t1)          # Save get_substr_int result into array
    
    lw $t0, 4($sp)          # Restore input pointer
    lw $ra, 8($sp)          # Restore return address
    addi $sp, $sp, 12

    addi $t1, $t1, 4        # Move to next array slot
    addi $s4, $s4, 1        # Increment return count
    j process_chunk_loop

end_process:
    sw $s4, 0($sp)          # Return substring count via stack
    jr $ra
    
get_substr_int:
    li $v1, 0               # Position counter
    li $t8, 0               # G Sum
    li $t9, 0               # H Sum
    li $s5, 0               # G count
    li $s6, 0               # H count

loop_chars:
    lb $t5, 0($a0)          # Load char from substring
    beq $t5, $zero, done_calc
