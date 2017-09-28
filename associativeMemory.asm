.text

.globl AssociativeMemory
AssociativeMemory:
    #; $a0  op_code (-1=alloc, 0=get, 1=set, 2=create, 3=delete, 4=copy, 5=reset)
    #; $a1  associative memory array object | number of elements to allocate
    #;      $a1+0: associative memory array keys base address
    #;      $a1+4: associative memory array elements base address
    #;      $a1+8: associative memory size
    #; $a2  key buffer (max 16 bytes)       | destination associative memory
    #; $a3  element (max 4 bytes)           | /
    #;
    #; $v0  procedure return value
    #; $v1  0,  ok
    #;      >0, procedure error code
    #;      <0, parameters error code

    #; --- INIT -----------------------------------------

    #; Save callee saved registers and return address
    subu $sp, $sp, 36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    #; Init registers
    li $s4, 4
    li $s6, 16
    li $v0, 0
    li $v1, 0

    #; --- CHECK PARAMETERS -----------------------------
    
    #; If op code is correct and method is _Alloc (opcode == -1) jump to opcode switch
    #; (no need to load associative memory info and to check key)
    li $t1, -1
    beq $t1, $a0, OpCodeSwitch
    #; Check op code (0 <= opcode <= 5)
    li $t1, 5
    slt $t0, $a0, $zero
    bne $t0, $zero, WrongOpCode
    slt $t0, $t1, $a0
    bne $t0, $zero, WrongOpCode
    #; OpCode is correct and associative memory info are needed so initialize them
    lw $t0, 0($a1)
    add $s0, $zero, $t0 #; $s0 = array keys base address
    lw $t0, 4($a1)
    add $s2, $zero, $t0 #; $s2 = array elements base address
    lw $t0, 8($a1)
    add $s1, $zero, $t0 #; $s1 = associative memory size
    #; Check if op code is >= 4 so key check is not needed
    slt $t0, $a0, $s4
    beq $t0, $zero, OpCodeSwitch
    #; Check null key not allowed
    li $t1, 0
    move $t0, $a2
    CheckParamKey:
        lw $t2, 0($t0)
        bne $t2, $zero, OpCodeSwitch
        addi $t1, 4
        bne $t1, 16, CheckParamKey
        j WrongNullKey


    #; --- OP CODE SWITCH -------------------------------

    #; Check for opcode=-1,0,1,2,3,4,5
    OpCodeSwitch:
    li $t0, -1
    beq $t0, $a0, Alloc
    addi $t0, 1
    beq $t0, $a0, Get
    addi $t0, 1
    beq $t0, $a0, Set
    addi $t0, 1
    beq $t0, $a0, Create
    addi $t0, 1
    beq $t0, $a0, Delete
    addi $t0, 1
    beq $t0, $a0, Copy
    addi $t0, 1
    beq $t0, $a0, Reset
    #; OpCodes jump to sub procedure
    Alloc:
        #; Call _Alloc sub procedure
        add $a0, $zero, $a1
        jal _Alloc
        j Completed
    Get:
        #; Call _GetElement sub procedure
        add $a0, $zero, $s0
        add $a3, $zero, $a2
        add $a2, $zero, $s2
        add $a1, $zero, $s1
        jal _GetElement
        j Completed
    Set:
        #; Call _CreateElement sub procedure
        subu $sp, $sp, 8
        sw $a2, 4($sp)
        sw $a3, 0($sp)
        add $a0, $zero, $s0
        add $a1, $zero, $s1
        add $a2, $zero, $s2
        jal _SetElement
        add $v1, $zero, $v0
        li $v0, 0
        j Completed
    Create:
        #; Call _CreateElement sub procedure
        subu $sp, $sp, 8
        sw $a2, 4($sp)
        sw $a3, 0($sp)
        add $a0, $zero, $s0
        add $a1, $zero, $s1
        add $a2, $zero, $s2
        jal _CreateElement
        add $v1, $zero, $v0
        li $v0, 0
        j Completed
    Delete:
        #; Call _DeleteElement sub procedure
        add $a0, $zero, $s0
        add $a3, $zero, $a2
        add $a2, $zero, $s2
        add $a1, $zero, $s1
        jal _DeleteElement
        add $v1, $zero, $v0
        li $v0, 0
        j Completed
    Copy:
        #; Call _CopyAssociativeMemory sub procedure
        add $a0, $zero, $s0
        add $a1, $zero, $s1
        add $a3, $zero, $a2
        add $a2, $zero, $s2
        jal _CopyAssociativeMemory
        add $v1, $zero, $v0
        li $v0, 0
        j Completed
    Reset:
        #; Call _Reset sub procedure
        add $a0, $zero, $s0
        add $a1, $zero, $s1
        add $a2, $zero, $s2
        jal _Reset
        li $v0, 0
        li $v1, 0
        j Completed
    #; OpCodes sub procedures completed
    Completed:
        #; Return values ($v0 = method return value, $v1 = method error code)
        j EndAssociativeMemory

    #; --- WRONG PARAMETERS -----------------------------

    #; Wrong Op Code
    WrongOpCode:
        li $v1, -1
        j EndAssociativeMemory
    #; Wrong null key not allowed
    WrongNullKey:
        li $v1, -2
        j EndAssociativeMemory

    #; --- RETURN ---------------------------------------

    EndAssociativeMemory:
        #; Reload callee saved registers and return address
        ReloadSavedValues:
            lw $ra, 32($sp)
            lw $s0, 28($sp)
            lw $s1, 24($sp)
            lw $s2, 20($sp)
            lw $s3, 16($sp)
            lw $s4, 12($sp)
            lw $s5, 8($sp)
            lw $s6, 4($sp)
            lw $s7, 0($sp)
            addu $sp, $sp, 36
    #; Terminate AssociativeMemory procedure
    Return:
        jr $ra

__FirstAvailableIndex:
    #; $a0  array keys base address
    #; $a1  array size
    #;
    #; $v0  >=0,index of first available index
    #;      -1, no index is available

    #; Init
    li $v0, -1
    li $t6, 16
    #; Iterate over every key in array keys
    li $t1, 0
    __IterateOverKeys:
        mult $t6, $t1
        mflo $t0
        add $t0, $t0, $a0
        #; Check all words of the selected key
        lw $t2, 0($t0)
        bne $t2, $zero, _IterateNextKey
        lw $t2, 4($t0)
        bne $t2, $zero, _IterateNextKey        
        lw $t2, 8($t0)
        bne $t2, $zero, _IterateNextKey        
        lw $t2, 12($t0)
        bne $t2, $zero, _IterateNextKey
        j __FoundFirstIndex #; if all 4 words are equals to zero element is empty and first index has been found
        _IterateNextKey:
        #; Increment index and check condition loop
        addi $t1, 1
        bne $t1, $a1, __IterateOverKeys
    #; No element is empty so no index is available
    li $v0, -1
    j __EndFirstAvailableIndex
    #; If an available index has been found set retun value equals to that index
    __FoundFirstIndex:
        add $v0, $zero, $t1
        j __EndFirstAvailableIndex
    #; Terminate FirstAvailableIndex sub procedure
    __EndFirstAvailableIndex:
        jr $ra

__FindByKey:
    #; $a0  arraystrings base address
    #; $a1  array size
    #; $a2  key address
    #;
    #; $v0  >=0,index of selected key
    #;      -1, no element with selected key

    #; Init
    li $v0, -1
    li $t6, 16
    #; Search every key in array keys
    li $t1, 0
    __SearchKey:
        mult $t6, $t1
        mflo $t0
        add $t0, $t0, $a0
        #; Search every word in selected key
        li $t7, 0
        __CheckWord:
            add $t2, $t0, $t7
            add $t3, $a2, $t7
            lw $t2, 0($t2)  #; word from selected key in array strings
            lw $t3, 0($t3)  #; word from passed string
            bne $t2, $t3, __CheckNextKey   #; if not equals word go to next key
            __CheckNextWord:
            addi $t7, 4
            bne $t7, $t6, __CheckWord
            j __FoundByKey  #; arrive here only if all 4 words of the key are equals
        __CheckNextKey:
        addi $t1, 1
        bne $t1, $a1, __SearchKey
    j __EndFindByKey
    #; If key has been found set return value equals to the found key index
    __FoundByKey:
        add $v0, $zero, $t1
        j __EndFindByKey
    #; Terminate FindByKey sub procedure
    __EndFindByKey:
        jr $ra

_Alloc:
    #; $a0  number of elements to allocate
    #;
    #; $v0  base address of array containing new associative memory base addresses (keys and element) allocated
    #;      $v0+0: associative memory array keys base address
    #;      $v0+4: associative memory array elements base address
    #;      $v0+8: associative memory size
    #; $v1  0,  ok
    #;      1,  wrong number of elements param

    #; Init
    li $t4, 4
    li $v1, 0
    add $t0, $zero, $a0
    #; Check if number is not negative nor equals to 0
    slt $t1, $zero, $a0
    beq $t1, $zero, _WrongNumberOfElements
    #; Prepare memory to store result object address
    li $v0, 9
    li $t1, 12
    add $a0, $zero, $t1
    syscall
    add $t7, $zero, $v0 #; $t7 now hold the return values array base address
    sw $t0, 8($t7)      #; store associative memory size in return value array third position
    #; Prepare number of bytes of array keys (size * 4 * 4) and array elements (size * 4)
    mult $t4, $t0
    mflo $t2 #; number of bytes for array elements
    mult $t4, $t2
    mflo $t1 #; number of bytes for array keys
    #; Allocate space for array keys
    li $v0, 9
    add $a0, $zero, $t1
    syscall
    sw $v0, 0($t7)
    #; Allocate space for array elements
    li $v0, 9
    add $a0, $zero, $t2
    syscall
    sw $v0, 4($t7)
    #; Initialize new associative memory with all zeros (_Reset)
    subu $sp, $sp, 8
    sw $ra, 0($sp)
    sw $t7, 4($sp)
    lw $a0, 0($t7)
    lw $a2, 4($t7)
    lw $a1, 8($t7)
    jal _Reset
    lw $ra, 0($sp)    
    lw $t7, 4($sp)
    addu $sp, $sp, 8
    #; Prepare return values
    add $v0, $zero, $t7
    j _EndAlloc
    #; Called if number of elements to allocate is <=0
    _WrongNumberOfElements:
        li $v1, 1
        j _EndAlloc
    #; Terminate Alloc subprocedure
    _EndAlloc:
        jr $ra

_GetElement:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address
    #; $a3  key base address
    #;
    #; $v0  ?,  element value
    #; $v1  0,  ok
    #;      1,  key not found / invalid

    #; Init subprocedure
    li $v0, 0
    li $v1, 0
    li $t4, 4
    #; Call _FindByKey to find index of key if exist, -1 otherwise
    subu $sp, $sp, 12
    sw $ra, 8($sp)
    sw $a2, 4($sp)
    sw $t4, 0($sp)
    add $a2, $zero, $a3
    jal __FindByKey
    lw $ra, 8($sp)
    lw $a2, 4($sp)
    lw $t4, 0($sp)
    addu $sp, $sp, 12
    #; Check __FindByKey return value
    add $t1, $zero, $v0
    slt $t7, $t1, $zero
    bne $t7, $zero, _KeyNotFound
    #; Calculate element index by using index from FindByKey
    mult $t4, $t1
    mflo $t7
    add $t7, $t7, $a2   #; target element address of array elements
    lw $v0, 0($t7)      #; return value (element value)
    li $v1, 0           #; return error code (no error)
    j _EndGetElement
    #; Called if key has not been found
    _KeyNotFound:
        li $v1, 1
    #; Terminate CreateElement sub procedure
    _EndGetElement:
        jr $ra

_SetElement:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address
    #; 4($sp)   key base address
    #; 0($sp)   element
    #;
    #; $v0  0,  ok
    #;      1,  key not found

    #; Init subprocedure
    li $v0, 1
    li $t4, 4
    #; Load key address and element from stackpointer
    lw $t0, 4($sp)  #; key base address
    lw $t2, 0($sp)  #; element
    addu $sp, $sp, 8
    #; Store actual registers values
    subu $sp, $sp, 16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t2, 4($sp)
    sw $t4, 0($sp)
    #; Call __FindByKey to find index of key if exist, -1 otherwise
    add $a3, $zero, $a2 #; switch $a3 with $a2 (now on $a3 will store array elements base address)
    add $a2, $zero, $t0
    jal __FindByKey
    #; Reload correct registers values
    lw $ra, 12($sp)
    lw $t0, 8($sp)
    lw $t2, 4($sp)
    lw $t4, 0($sp)
    addu $sp, $sp, 16  
    #; Check __FindByKey return value   
    slt $t7, $v0, $zero
    bne $t7, $zero, _ElementNotFound
    add $t7, $zero, $v0       
    #; Set element at index found in __FindByKey
    mult $t4, $t7
    mflo $t0
    add $t0, $a3, $t0
    sw $t2, 0($t0)  #; store element in arrayelements
    li $v0, 0       #; error code if everything has been succesfull
    j _EndSetElement
    #; Called if no element has been found by input key
    _ElementNotFound:
        li $v0, 1
        j _EndSetElement
    #; Terminate SetElement subprocedure
    _EndSetElement:
        jr $ra

_CreateElement:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address
    #; 4($sp)   key base address
    #; 0($sp)   element
    #;
    #; $v0  0,  ok
    #;      1,  key already taken
    #;      2,  no available space in associative memory

    #; Init subprocedure
    li $v0, 0
    li $t4, 4
    #; Load key address and element from stackpointer
    lw $t0, 4($sp)  #; key base address
    lw $t2, 0($sp)  #; element
    addu $sp, $sp, 8
    #; Store actual registers values
    subu $sp, $sp, 16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t2, 4($sp)
    sw $t4, 0($sp)
    #; Call __FindByKey to find index of key if exist, -1 otherwise
    add $a3, $zero, $a2 #; switch $a3 with $a2 (now on $a3 will store array elements base address)
    add $a2, $zero, $t0
    jal __FindByKey
    slt $t7, $v0, $zero
    beq $t7, $zero, _KeyAlreadyTaken
    #; Call __FirstAvailableIndex to find first available index
    jal __FirstAvailableIndex
    add $t1, $zero, $v0 #; $t1 now holds the first available index    
    #; Reload correct registers values
    lw $t0, 8($sp)
    lw $t2, 4($sp)
    lw $t4, 0($sp)
    addu $sp, $sp, 12
    #; Check if first available index is >= 0, otherwise there is no empty index to create new element
    slt $t7, $t1, $zero
    bne $t7, $zero, _NoAvailableIndex
    #; Calculate insert index by using first available index
    mult $t4, $t1
    mflo $t7
    mult $t4, $t7
    mflo $t6
    add $t6, $t6, $a0 #; array keys insert address
    add $t7, $t7, $a3 #; array elements insert address
    sw $t2, 0($t7)    #; store element into array elements
    lw $t5, 0($t0)    #; store key into array keys
    sw $t5, 0($t6)
    lw $t5, 4($t0)   
    sw $t5, 4($t6)
    lw $t5, 8($t0)   
    sw $t5, 8($t6)
    lw $t5, 12($t0)   
    sw $t5, 12($t6)
    li $v0, 0         #; error code 0 if everything was succesfull
    j _EndCreateElement
    #; Called if key has already been taked
    _KeyAlreadyTaken:
        li $v0, 1
        addu $sp, $sp, 12
        j _EndCreateElement
    #; Called if there is no more space in the associative memory to store another element
    _NoAvailableIndex:
        li $v0, 2
        j _EndCreateElement
    #; Terminate CreateElement sub procedure
    _EndCreateElement:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_DeleteElement:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address
    #; $a3  key base address
    #;
    #; $v0  0,  ok
    #;      1,  key not found / invalid

    #; Init sub procedure
    li $v0, 0
    li $t4, 4
    #; Call _FindByKey to find index of key if exist, -1 otherwise
    subu $sp, $sp, 12
    sw $ra, 8($sp)
    sw $a2, 4($sp)
    sw $t4, 0($sp)
    add $a2, $zero, $a3
    jal __FindByKey
    lw $ra, 8($sp)
    lw $a2, 4($sp)
    lw $t4, 0($sp)
    addu $sp, $sp, 12
    #; Check __FindByKey return value
    slt $t7, $t1, $zero
    bne $t7, $zero, _DeletableKeyNotFound
    add $t1, $zero, $v0
    #; Calculate insert index by using first available index
    mult $t4, $t1
    mflo $t7
    mult $t4, $t7
    mflo $t6
    add $t6, $t6, $a0 #; array keys insert address
    add $t7, $t7, $a2 #; array elements insert address
    sw $zero, 0($t7)  #; store zero into array elements
    sw $zero, 0($t6)  #; store zero into array keys
    sw $zero, 4($t6)
    sw $zero, 8($t6)
    sw $zero, 12($t6)
    li $v0, 0         #; error code 0 if everything was succesfull
    j _EndDeleteElement
    #; Called if key has not been found
    _DeletableKeyNotFound:
        li $v0, 1
        j _EndDeleteElement
    #; Terminate _DeleteElement sub procedure
    _EndDeleteElement:
        jr $ra

_CopyAssociativeMemory:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address
    #; $a3  destination associative memory array object
    #;
    #; $v0  0,  ok
    #;      1,  wrong origin associative memory size
    #;      2,  wrong destination associative memory size

    #; Init subprocedure
    li $t4, 4
    li $t6, 16
     #; Check origin associative memory size
    slt $t0, $zero, $a1
    beq $t0, $zero, _WrongOriginAssMemorySize
    #; Load destination associative memory array object
    lw $t0, 0($a3) #; $t0 = dest array keys base address
    lw $t2, 4($a3) #; $t2 = dest array elements base address
    lw $t1, 8($a3) #; $t1 = dest associative memory size
    slt $t3, $t1, $a1
    bne $t3, $zero, _WrongDestAssMemorySize

    #; Reset all elements of DestAssMemory
    subu $sp, $sp, 36
    sw $ra, 32($sp)
    sw $a0, 28($sp)
    sw $a1, 24($sp)
    sw $a2, 20($sp)
    sw $t0, 16($sp)
    sw $t2, 12($sp)
    sw $t1, 8($sp)
    sw $t4, 4($sp)
    sw $t6, 0($sp)
    move $a0, $t0
    move $a1, $t1
    move $a2, $t2
    jal _Reset
    lw $ra, 32($sp)
    lw $a0, 28($sp)
    lw $a1, 24($sp)
    lw $a2, 20($sp)
    lw $t0, 16($sp)
    lw $t2, 12($sp)
    lw $t1, 8($sp)
    lw $t4, 4($sp)
    lw $t6, 0($sp)
    addu $sp, $sp, 36
    
    #; Loop over each origin element
    li $t1, 0
    li $v0, 0 #; no error code
    _IterateOverOrigin:
        lw $t7, 0($a0)  #; copy paste key
        sw $t7, 0($t0)
        lw $t7, 4($a0)
        sw $t7, 4($t0)
        lw $t7, 8($a0)
        sw $t7, 8($t0)
        lw $t7, 12($a0)
        sw $t7, 12($t0)
        lw $t7, 0($a2)  #; copy paste element
        sw $t7, 0($t2)
        #; Check loop condition and increment index
        addi $t1, 1
        beq $t1, $a1, _EndCopyAssociativeMemory
        add $a0, $a0, $t6
        add $t0, $t0, $t6
        add $a2, $a2, $t4
        add $t2, $t2, $t4
        j _IterateOverOrigin
    #; Called if destination associative memory size is smaller than origin one
    _WrongOriginAssMemorySize:
        li $v0, 1
        j _EndCopyAssociativeMemory
    #; Called if destination associative memory size is smaller than origin one
    _WrongDestAssMemorySize:
        li $v0, 2
        j _EndCopyAssociativeMemory
    #; Terminate _CopyAssociativeMemory sub procedure
    _EndCopyAssociativeMemory:
        jr $ra

_Reset:
    #; $a0  array keys base address
    #; $a1  arrays size
    #; $a2  array elements base address

    #; Init sub procedure
    li $t1, 0
    li $t4, 4
    li $t6, 16
    #; Check associative memory size
    slt $t0, $zero, $a1
    beq $t0, $zero, _EndReset
    #; Loop over associative memory elements
    _ResetItem:
        sw $zero, 0($a0)
        sw $zero, 4($a0)
        sw $zero, 8($a0)
        sw $zero, 12($a0)
        sw $zero, 0($a2)
        #; Check loop condition and increment index
        addi $t1, 1
        beq $t1, $a1, _EndReset
        add $a0, $a0, $t6
        add $a2, $a2, $t4
        j _ResetItem
    #; Terminate __Reset sub procedure
    _EndReset:
        jr $ra