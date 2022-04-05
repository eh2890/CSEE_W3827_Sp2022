        .data
DecryptStringSpace: .space 400 # 400 bytes of space, more than enough...

AVCorrect:        .asciiz "\nCorrect Assessment"
AVKeyName:       .asciiz " keyval "
AVFailLead:      .asciiz "Test "
AVFalsePos:        .asciiz ": failed with correct key\n"
AVFalseNeg:      .asciiz ": failed (says correct) with wrong key\n"
AVStartTest:     .asciiz "\nStarting Test "
NewLine:        .asciiz "\n"
newline:        .asciiz "\n"
AVDone:         .asciiz "\nALL DONE\n"


        
TestData:
        # format is good key, bad key, encode-phrase-len (in words), encode phrase
        .word 12, 25, 2, 0x44414337, 0x39483940, 0
        .word 17, 30, 6, 0x4334312f, 0x2f413443, 0x3d303743, 0x3534312f, 0x2f34413e, 0
        .word 0, 0, 0


.text

main:
        la $t0, TestData
        li $t1, 0
        li $t4, 1
AddVerifyTestLoop:
        
        add $t2, $t0, $t1
        lw $t3, 0($t2)
        beq $t3, $zero, AddVerifyTestDone
        la $a0, AVStartTest
        li $v0, 4
        syscall
        move $a0, $t4
        li $v0, 1
        syscall
        la $a0, NewLine
        li $v0, 4
        syscall

        move $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        move $a0, $t2
        add $a0, $a0, 12
        la $a1, DecryptStringSpace
        sw $t0, -4($sp)
        sw $t1, -8($sp)
        sw $a0, -12($sp)
        sw $a1, -16($sp)
        sw $a2, -20($sp)
        sw $t2, -24($sp)
        sw $t4, -28($sp)
        
        addi $sp, $sp, -28
        jal AddAndVerify
        addi $sp, $sp, 28
        lw $t0, -4($sp)
        lw $t1, -8($sp)
        lw $a0, -12($sp)
        lw $a1, -16($sp)
        lw $a2, -20($sp)
        lw $t2, -24($sp)
        lw $t4, -28($sp)
        li $t3, 1
        beq $t3, $v0, AddVerifyNextCase

        la $a0, AVFailLead
        li $v0, 4
        syscall
        move $a0, $t4
        li $v0, 1
        syscall
        la $a0, AVKeyName
        li $v0, 4
        syscall
        lw $a0, 0($t2)
        li $v0, 1
        syscall
        la $a0, AVFalsePos
        li $v0, 4
        syscall


        ### Now try with bad key
AddVerifyNextCase:
        lw $t3, 4($t2)
        move $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        sll $a2, $a2, 8
        or $a2, $a2, $t3
        move $a0, $t2
        add $a0, $a0, 12
        la $a1, DecryptStringSpace
        sw $t0, -4($sp)
        sw $t1, -8($sp)
        sw $a0, -12($sp)
        sw $a1, -16($sp)
        sw $a2, -20($sp)
        sw $t2, -24($sp)
        sw $t4, -28($sp)
        
        addi $sp, $sp, -28
        jal AddAndVerify
        addi $sp, $sp, 28
        lw $t0, -4($sp)
        lw $t1, -8($sp)
        lw $a0, -12($sp)
        lw $a1, -16($sp)
        lw $a2, -20($sp)
        lw $t2, -24($sp)
        lw $t4, -28($sp)

        beq $zero, $v0, AddVerifyNextIter

        la $a0, AVFailLead
        li $v0, 4
        syscall
        move $a0, $t4
        li $v0, 1
        syscall
        la $a0, AVKeyName
        li $v0, 4
        syscall
        lw $a0, 4($t2)
        li $v0, 1
        syscall
        la $a0, AVFalseNeg
        li $v0, 4
        syscall

AddVerifyNextIter:
        la $a0, DecryptStringSpace
        li $v0, 4
        syscall
        addi $t4, $t4, 1
        lw $t3, 8($t2)
        sll $t3, $t3, 2
        add $t1, $t1, $t3
        addi $t1, $t1, 16
        j AddVerifyTestLoop
        
AddVerifyTestDone:
        la $a0, AVDone
        li $v0, 4
        syscall
        li $v0, 10
        syscall
        
        

        
        ############# Put Code for AddAndVerify, IsCandidate, WordDecrypt Here
