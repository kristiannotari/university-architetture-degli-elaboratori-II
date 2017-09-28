.data
    .align 2
    testkey:        .asciiz "testkey1testke\n"
    testkey2:       .asciiz "testkey2testke\n"
    testkey3:       .asciiz "testkey3testke\n"
    testkey4:       .asciiz "testkey4testke\n"
    testkey5:       .asciiz "testkey5testke\n"
    testkey6:       .asciiz "testkey6testke\n"
    testkey7:       .asciiz "testkey7testke\n"
    testkey8:       .asciiz "testkey8testke\n"
    testkey9:       .asciiz "testkey9testke\n"
    testkey0:       .asciiz "testkey0testke\n"
    returnvalue:    .asciiz "\nMETHOD RETURN VALUE: "
    returnerror:    .asciiz "\nMET/PARM ERROR CODE: "
    welcome:        .asciiz "\nMAIN\n"
    objectNames:    .asciiz "\n\nOBJECT NAMES in object library instance"
    divider:        .asciiz "\n-"
    .align 2
    buffer:         .space 16
	
.text

.globl main
main:
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    # ask object name
    li $v0, 8
    la $a0, buffer
    li $a1, 16
    syscall
    li $v0, 4
    syscall
    
    #; instantiate object library
    li $a0, -1
    jal Object
    move $s0, $v0 #; $s0 now holds the object library instance

    #; create object
    li $a0, 6
    move $a1, $s0
    la $a2, buffer
    jal Object

    #; create object
    li $a0, 6
    move $a1, $s0
    la $a2, testkey
    jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey2
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey3
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey4
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey5
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey6
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey7
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey8
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey9
    # jal Object
    # #; create object
    # li $a0, 6
    # move $a1, $s0
    # la $a2, testkey0
    # jal Object


    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey2
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey2
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey3
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey4
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey5
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey6
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey7
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey8
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey9
    jal Object

    # #; add object property
    # li $a0, 1
    # move $a1, $s0
    # la $a2, testkey
    # la $a3, buffer
    # jal Object

    #; set object property
    li $a0, 3
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey
    subu $sp, $sp, 4
    li $t0, 999
    sw $t0, 0($sp)
    jal Object
    #; set object property
    li $a0, 3
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey2
    subu $sp, $sp, 4
    li $t0, 133
    sw $t0, 0($sp)
    jal Object

    # #; copy object
    # li $a0, 4
    # move $a1, $s0
    # la $a2, buffer
    # la $a3, testkey
    # jal Object

    #; clone object
    li $a0, 5
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey
    jal Object

    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey0
    jal Object
    #; add object property
    li $a0, 1
    move $a1, $s0
    la $a2, buffer
    la $a3, buffer
    jal Object

    # #; delete property of object
    # li $a0, 2
    # move $a1, $s0
    # la $a2, testkey
    # la $a3, testkey2
    # jal Object

    #; set object property
    li $a0, 3
    move $a1, $s0
    la $a2, testkey
    la $a3, testkey
    subu $sp, $sp, 4
    li $t0, 134
    sw $t0, 0($sp)
    jal Object

    #; get object property
    li $a0, 0
    move $a1, $s0
    la $a2, buffer
    la $a3, testkey
    jal Object

    # #; delete object
    # li $a0, 8
    # move $a1, $s0
    # la $a2, testkey
    # jal Object

    # #; get object names
    # li $a0, -2
    # move $a1, $s0
    # jal Object

    # #; get property names
    # li $a0, 7
    # move $a1, $s0
    # la $a2, testkey
    # jal Object

    #; PRINT INFO
    move $t0, $v0
    move $t1, $v1

    li $v0, 4
    la $a0, returnvalue
    syscall
    li $v0, 1
    move $a0, $t0
    syscall
    li $v0, 4
    la $a0, returnerror
    syscall
    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 4
    la $a0, objectNames
    syscall

    beq $t1, $zero, _EndMain
    addi $t1, -1
    _LoopOverNames:
        li $v0, 4
        la $a0, divider
        syscall
        mult $t1, $t6
        mflo $t3
        add $t3, $t0, $t3
        li $t4, 3 #; index for subloop
        _LoopOverObjectName:
            lb $t5, 0($t3)
            li $v0, 11
            move $a0, $t5
            syscall
            lb $t5, 1($t3)
            li $v0, 11
            move $a0, $t5
            syscall
            lb $t5, 2($t3)
            li $v0, 11
            move $a0, $t5
            syscall
            lb $t5, 3($t3)
            li $v0, 11
            move $a0, $t5
            syscall
            #; STAMPA QUI
            _NextObjectNamePart:
                addi $t4, -1
                addi $t3, 4
                slt $t5, $t4, $zero
                bne $t5, $zero, _NextObject
                j _LoopOverObjectName
        _NextObject:
            addi $t1, -1
            slt $t5, $t1, $zero
            bne $t5, $zero, _EndMain
            j _LoopOverNames

    _EndMain:

    lw $ra, 0($sp)
    addu $sp, $sp, 4
    jr $ra