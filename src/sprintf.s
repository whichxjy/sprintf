########################################################################
# sprintf                                                              #
########################################################################
# $a0 -> address of buffer                                             #
# $a1 -> address of format                                             #
# $a2,$a3,stack -> values to be converted to printable character       #
########################################################################
# (return value) $v0 -> the number of characters in the buffer         #
#                       (not including the null at the end)            #
########################################################################
sprintf:
    # push $a2 and $a3 onto the stack for convenience
    sw      $a2, 8($sp)
    sw      $a3, 12($sp)

    addi    $s0, $sp, 8    # s0 -> the first additional arg
    li      $v0, 0   # v0 = 0
    
scan:
    # scan format string
    lb      $t0, 0($a1)  # t0 -> char in format

    beq     $t0, $zero, end_sprintf     # if char = null, end
    beq     $t0, '%', check_specifier   # else if char = '%', check specifier

    sb      $t0, 0($a0)                 # else write char to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++
    
    addi    $a1, $a1, 1    # format++
    j       scan  # continue to scan

end_sprintf:
    li      $t0, 0      # write null to buffer
    sb      $t0, 0($a0) # write $t0(char) to buffer
    jr      $ra         # end sprintf function

#------------------------------------------------------------------------

check_specifier:
    addi    $a1, $a1, 1
    lb      $t0, 0($a1)  # t0 -> next format char

    beq     $t0, 'b', handle_bin
    beq     $t0, 'd', handle_dec
    beq     $t0, 'u', handle_unsigned
    beq     $t0, 'x', handle_hex
    beq     $t0, 'o', handle_oct
    beq     $t0, 'c', handle_char
    beq     $t0, 's', handle_str
    beq     $t0, '%', handle_percent

########################################################################
# unsigned binary
########################################################################
handle_bin:
    addi    $sp, $sp, -12
    sw      $a1, 0($sp)  # save ra, a1 and a2
    sw      $a2, 4($sp)
    sw      $ra, 8($sp)

    # a0 -> buffer
    lw      $a1, 0($s0)  # a1 -> current arg, the int to write
    li      $a2, 2       # base = 2
    jal     write_int

    lw      $a1, 0($sp)  # restore ra, a1 and a2
    lw      $a2, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12
  
    addi    $s0, $s0, 4     # s0 -> next arg
    addi    $a1, $a1, 1     # format++
    j       scan # continue to scan

########################################################################
# signed decimal
########################################################################
handle_dec:
    addi    $sp, $sp, -12
    sw      $a1, 0($sp)  # save ra, a1 and a2
    sw      $a2, 4($sp)
    sw      $ra, 8($sp)

    # a0 -> buffer
    lw      $t1, 0($s0)  # t1 -> current arg, the int to write
    bgez    $t1, write_natural_num # if t1 >= 0, write t1

    li      $t0, '-' # else write negative sign
    sb      $t0, 0($a0)  # write $t0(char) to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++

    not     $t1, $t1    # get complement number: flip bits and add 1
    addi    $t1, $t1, 1

write_natural_num:
    # a0 -> buffer
    move    $a1, $t1
    li      $a2, 10      # base = 10
    jal     write_int

    lw      $a1, 0($sp)  # restore ra, a1 and a2
    lw      $a2, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12
  
    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

########################################################################
# unsigned decimal
########################################################################
handle_unsigned:
    addi    $sp, $sp, -12
    sw      $a1, 0($sp)  # save ra, a1 and a2
    sw      $a2, 4($sp)
    sw      $ra, 8($sp)

    # a0 -> buffer
    lw      $a1, 0($s0)  # a1 -> current arg, the int to write
    li      $a2, 10      # base = 10
    jal     write_int

    lw      $a1, 0($sp)  # restore ra, a1 and a2
    lw      $a2, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12
  
    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

########################################################################
# unsigned hexadecimal
########################################################################
handle_hex:
    addi    $sp, $sp, -12
    sw      $a1, 0($sp)  # save ra, a1 and a2
    sw      $a2, 4($sp)
    sw      $ra, 8($sp)

    # a0 -> buffer
    lw      $a1, 0($s0)  # a1 -> current arg, the int to write
    li      $a2, 16      # base = 16
    jal     write_int

    lw      $a1, 0($sp)  # restore ra, a1 and a2
    lw      $a2, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12
  
    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

########################################################################
# unsigned octal
########################################################################
handle_oct:
    addi    $sp, $sp, -12
    sw      $a1, 0($sp)  # save ra, a1 and a2
    sw      $a2, 4($sp)
    sw      $ra, 8($sp)

    # a0 -> buffer
    lw      $a1, 0($s0)  # a1 -> current arg, the int to write
    li      $a2, 8       # base = 8
    jal     write_int

    lw      $a1, 0($sp)  # restore ra, a1 and a2
    lw      $a2, 4($sp)
    lw      $ra, 8($sp)
    addi    $sp, $sp, 12
  
    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

########################################################################
# character
########################################################################
handle_char:
    lb      $t0, 0($s0)  # t0 -> current arg, the char to write
    sb      $t0, 0($a0)  # write $t0(char) to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++

    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan


########################################################################
# string
########################################################################
handle_str:
    lw      $t1, 0($s0)  # t1 -> current arg, a pointer to string

write_char:
    lb      $t0, 0($t1)  # t0 -> the char in the string
    beq     $t0, $zero, end_write_char    # if t0 = null, end write_char
    sb      $t0, 0($a0)  # write $t0(char) to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++
    addi    $t1, $t1, 1    # string pointer++(point to next char)
    j       write_char

end_write_char:
    addi    $s0, $s0, 4    # s0 -> next arg
    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

########################################################################
# literal '%' character
########################################################################
handle_percent:
    #no argument required
    li      $t0, '%' # t0 <- '%'
    sb      $t0, 0($a0)  # write $t0(char) to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++

    addi    $a1, $a1, 1    # format++
    j       scan # continue to scan

#------------------------------------------------------------------------

###########################################################
# write_int                                               #
###########################################################
# $a0 -> address of buffer                                #
# $a1 -> the integer to write to buffer                   #
# $a2 -> base                                             #
###########################################################
write_int:
    addi    $sp, $sp, -8
    sw      $ra, 0($sp)
    
    div     $a1, $a2
    mfhi    $t0    # $t0 <- $a1 % a2 (int % base)
    addi    $t0, $t0, '0'  # $t0 += '0'
    bgt     $t0, '9', over_nine  # if t0 > '9' (t0 = a/b/c/d/e/f), then t0 <- t0 + 39 
next_dig:
    mflo    $a1    # $a1 /= base
    beqz    $a1, write_one_dig  # if( $a1 != 0 ) { 
    sw      $t0, 4($sp)         #   save $t0 on our stack
    jal     write_int           #   write_int
    lw      $t0, 4($sp)         #   restore $t0
                                # } 

write_one_dig:
    sb      $t0, 0($a0)  # write $t0(char) to buffer
    addi    $v0, $v0, 1    # counter++
    addi    $a0, $a0, 1    # buffer++

    lw      $ra,0($sp)  # restore return address
    addi    $sp, $sp, 8    # restore stack
    jr      $ra  # return

over_nine:
    addi    $t0, $t0, 39
    j       next_dig

#------------------------------------------------------------------------