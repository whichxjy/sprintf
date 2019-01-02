.data

buffer: .space  20000   # 2000 bytes of empty space   
format: .asciiz "bin: %b, dec: %d, unsigned dec: %u, hex: 0x%x, oct: 0%o, char: %c, string: %s, percent: %%\n"
str:    .asciiz "thirty-nine"
chrs:   .asciiz " characters:\n"

.text

.globl sprintf

main:
    addi    $sp, $sp, -40

    # $v0 = sprintf(buffer, format, 255, -255, 255, 255, 255, 'F', str)
    
    la      $a0, buffer # arg 0 <- buffer
    la      $a1, format # arg 1 <- format
    li      $a2, 255    # arg 2 <- 255
    li      $a3, -255   # arg 3 <- -255

    addi    $t0, $0, 255
    sw      $t0, 16($sp)    # arg 4 <- 255
    
    addi    $t0, $0, 255
    sw      $t0, 20($sp)    # arg 5 <- 255

    addi    $t0, $0, 255
    sw      $t0, 24($sp)    # arg 6 <- 255

    addi    $t0, $0, 'F'
    sw      $t0, 28($sp)    # arg 7 <- 'F'

    la      $t0, str
    sw      $t0, 32($sp)    # arg 8 <- str

    sw      $ra, 36($sp)    # save return address
    jal     sprintf         # $v0 = sprintf(...)

    # print the return value from sprintf using put_int()
    add     $a0, $v0, $0    # $a0 <- $v0
    jal     put_int         # put_int($a0)

    ## output the string 'chrs' then 'buffer'
    li      $v0, 4
    la      $a0, chrs
    syscall
    #puts   chrs        # output string chrs
    
    li      $v0, 4
    la      $a0, buffer
    syscall
    #puts   buffer      # output string buffer
    
    addi    $sp, $sp, 40    # restore stack
    li      $v0, 10         # terminate program
    syscall

# put_int writes the number in $a0 to the console in decimal.
put_int:
    addi    $sp, $sp, -8
    sw      $ra, 0($sp)

    remu    $t0, $a0, 10    # $t0 <- $a0 % 10
    addi    $t0, $t0, '0'   # $t0 += '0' ($t0 is now a digit character)
    divu    $a0, $a0, 10    # $a0 /= 10
    beqz    $a0, put_one_dig    # if( $a0 != 0 ) { 
    sw      $t0, 4($sp)         #   save $t0 on our stack
    jal     put_int             #   putint()
    lw      $t0, 4($sp)         #   restore $t0
                                # } 
put_one_dig:
    move    $a0, $t0
    li      $v0, 11
    syscall     # putc #$t0
    #putc   $t0         # output the digit character $t0
    lw      $ra, 0($sp) # restore return address
    addi    $sp, $sp, 8 # restore stack
    jr      $ra