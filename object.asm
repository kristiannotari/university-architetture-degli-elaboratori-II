.text

.globl Object
Object:
    #; $a0  method code (   
    #;                      -2=get objects names        type A
    #;                      -1=init library             type 0
    #;                       0=get key value of object  type D
    #;                       1=add key to object        type D
    #;                       2=delete key of object     type D
    #;                       3=set key value of object  type E
    #;                       4=copy object by name      type C
    #;                       5=clone object by name     type C
    #;                       6=create object            type B
    #;                       7=get object keys          type B
    #;                       8=delete object            type B
    #;                  )
    #; TYPE 0
    #; TYPE A
    #; $a1  library instance
    #; TYPE B
    #; $a1  library instance
    #; $a2  buffer of object name string (max 16 bytes)
    #; TYPE C
    #; $a1  library instance    
    #; $a2  buffer of origin object name string (max 16 bytes)
    #; $a3  buffer of destination object name string (max 16 bytes)
    #; TYPE D
    #; $a1  library instance
    #; $a2  buffer of object name string (max 16 bytes)
    #; $a3  buffer of key string
    #; TYPE E
    #; $a1  library instance
    #; $a2  buffer of object name string (max 16 bytes)
    #; $a3  buffer of key string
    #; $sp+0,   element value
    #;
    #; $v0  method return value
    #; $v1  0,  ok
    #;      >0, method error code
    #;      <0, parameters error code

    #; --- INIT -----------------------------------------

    #; If method type E then get element from stack
    move $t3, $s3 #; save possible stack saver register
    li $t0, 3
    bne $t0, $a0, Start
    lw $s3, 0($sp)
    addu $sp, $sp, 4
    #; Save callee saved registers and return address
    Start:
    subu $sp, $sp, 36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $t3, 16($sp) #; save $s3 substitute register
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    #; Init registers
    move $s0, $a1
    li $s4, 4
    li $s6, 16


    #; --- CHECK PARAMETERS -----------------------------

    #; Check method code (-2 <= method code <= 8)
    li $t0, -2
    li $t1, 8
    slt $t2, $a0, $t0
    bne $t2, $zero, WrongMethodCode
    slt $t2, $t1, $a0
    bne $t2, $zero, WrongMethodCode
    slt $t2, $a0, $zero
    bne $t2, $zero, MethodCodeSwitch #; type A or 0 jump to method switch
    #; Type is not A or 0 so check key string size, endofline char presence and absence of unallowed chars
    add $t6, $zero, $a2 #; string name of object to be checked always
    CheckParamString:
    li $t1, 0
    li $t3, 15
    li $t2, 10
    li $t4, 48
    li $t5, 126
    CheckParamChar:
        add $t0, $t6, $t1
        lb $t0, 0($t0)
        beq $t0, $t2, EndCheckParamString
        slt $t7, $t0, $t4
        bne $t7, $zero, WrongStringUnallowedChar
        slt $t7, $t5, $t0
        bne $t7, $zero, WrongStringUnallowedChar
        addi $t1, 1
        bne $t3, $t1, CheckParamChar
        j WrongStringEndOfLine
    EndCheckParamString:
        #; Check if EndOfLine char is not at first position, otherwise string is not allowed
        beq $t1, $zero, WrongStringNoChar
    #; If method type C, D or E then check also another string
    slt $t2, $s4, $a0
    bne $t2, $zero, MethodCodeSwitch
    beq $t6, $a3, MethodCodeSwitch
    move $t6, $a3
    j CheckParamString


    #; --- METHOD CODE SWITCH ---------------------------
    
    #; Check for method codes=-2,-1,0,1,2,3,4,5,6,7,8
    MethodCodeSwitch:
    li $t0, -2
    beq $t0, $a0, GetObjectsNames
    addi $t0, 1
    beq $t0, $a0, Init
    addi $t0, 1
    beq $t0, $a0, GetKeyValue
    addi $t0, 1
    beq $t0, $a0, AddKey
    addi $t0, 1
    beq $t0, $a0, DeleteKey
    addi $t0, 1
    beq $t0, $a0, SetKeyValue
    addi $t0, 1
    beq $t0, $a0, CopyObject
    addi $t0, 1
    beq $t0, $a0, CloneObject
    addi $t0, 1
    beq $t0, $a0, CreateObject
    addi $t0, 1
    beq $t0, $a0, GetObjectKeys
    addi $t0, 1
    beq $t0, $a0, DeleteObject
    #; Jump to methods
    GetObjectsNames:
        #; Call _GetObjectNames method
        move $a0, $a1
        jal _GetObjectNames
        j Completed
    Init:
        #; Call _Init method
        li $a0, 8 #; default library associative memory size
        jal _Init
        j Completed
    GetKeyValue:
        #; Call _GetKeyValue method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        jal _GetKeyValue
        j Completed
    AddKey:
        #; Call _AddKey method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        jal _AddKey
        move $v1, $v0
        li $v0, 0
        j Completed
    DeleteKey:
        #; Call _DeleteKey method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        jal _DeleteKey
        move $v1, $v0
        li $v0, 0
        j Completed
    SetKeyValue:
        #; Call _SetKeyValue method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        move $a3, $s3
        jal _SetKeyValue
        move $v1, $v0
        li $v0, 0
        j Completed
    CopyObject:
        #; Call _CopyObject method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        jal _CopyObject
        move $v1, $v0
        li $v0, 0
        j Completed
    CloneObject:
        #; Call _CloneObject method
        move $a0, $a1
        move $a1, $a2
        move $a2, $a3
        jal _CloneObject
        move $v1, $v0
        li $v0, 0
        j Completed
    CreateObject:
        #; Call _CreateObject method
        move $a0, $a1
        move $a1, $a2
        jal _CreateObject
        move $v1, $v0
        li $v0, 0
        j Completed
    GetObjectKeys:
        #; Call _GetObjectKeys method
        move $a0, $a1
        move $a1, $a2
        jal _GetObjectKeys
        j Completed
    DeleteObject:
        #; Call _DeleteObject method
        move $a0, $a1
        move $a1, $a2
        jal _DeleteObject
        move $v1, $v0
        li $v0, 0
        j Completed
    #; Methods completed
    Completed:
        #; Return values ($v0 = method return value, $v1 = method error code)
        j EndObject


    #; --- WRONG PARAMETERS -----------------------------

    #; Wrong Method Code
    WrongMethodCode:
        li $v1, -1
        j EndObject
    #; Absence of EndOfLine char (code=10) in first 16 string bytes
    WrongStringEndOfLine:
        li $v1, -2
        j EndObject
    #; Presence of unallowed char in first 16 string bytes
    WrongStringUnallowedChar:
        li $v1, -3
        j EndObject
    #; Called if string has no valid char before EndOfLine char (code=10)
    WrongStringNoChar:
        li $v1, -4
        j EndObject

    #; --- RETURN ---------------------------------------

    EndObject:
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
    #; Terminate Object Library
    Return:
        jr $ra

_GetObjectNames:
    #; $a0  Object library instance
    #;
    #; $v0  array address of string keys
    #; $v1  0, no array created due to no objects in library
    #;      n, size of array created

    #; Init
    li $v0, 0
    li $v1, 0
    li $t6, 16

    #; Get library associative info
    lw $t0, 0($a0) #; keys array
    lw $t2, 8($a0) #; size

    #; Loop over objects (library associative memory)
    li $t1, 0 #; index
    li $t7, 0 #; how many object names there are
    _LoopOverObjects:
        mult $t1, $t6
        mflo $t3
        add $t3, $t0, $t3
        li $t4, 3 #; index for subloop
        subu $sp, $sp, 4 #; mark index as not significant
        sw $zero, 0($sp)
        _LoopOverObjectName:
            lw $t5, 0($t3)
            beq $t5, $zero, _NextObjectNamePart
            addi $t7, 1
            sw $t7, 0($sp) #; mark index as significant
            j _NextObject
            _NextObjectNamePart:
                addi $t4, -1
                addi $t3, 4
                slt $t5, $t4, $zero
                bne $t5, $zero, _NextObject
                j _LoopOverObjectName
        _NextObject:
            addi $t1, 1
            beq $t1, $t2, _AllocObjectNamesArray
            j _LoopOverObjects


    #; Alloc array to store object names
    _AllocObjectNamesArray:
        li $v0, 9
        mult $t6, $t7
        mflo $a0
        syscall #; v0 now holds the correct return array address
        add $v1, $zero, $t7

    #; Loop over objects (library associative memory) to store object names
    add $t1, $zero, $t2 #; index
    addi $t1, -1
    addi $t7, -1
    mult $t7, $t6
    mflo $t7
    add $t7, $t7, $v0
    addi $t7, 12
    _LoopOverObjectsToStore:
        mult $t1, $t6
        mflo $t3
        add $t3, $t0, $t3
        lw $t5, 0($sp)
        addu $sp, $sp, 4
        beq $t5, $zero, _NextObjectToStore
        li $t4, 3 #; index for subloop
        addi $t3, 12
        _LoopOverObjectNameToStore:
            lw $t5, 0($t3)
            sw $t5, 0($t7)
            _NextObjectNamePartToStore:
                addi $t4, -1
                addi $t3, -4
                addi $t7, -4
                slt $t5, $t4, $zero
                bne $t5, $zero, _NextObjectToStore
                j _LoopOverObjectNameToStore
        _NextObjectToStore:
            addi $t1, -1
            slt $t5, $t1, $zero
            bne $t5, $zero, _EndGetObjectNames
            j _LoopOverObjectsToStore

    #; Called if there is no object in object library
    _NoObjectInLibraryInstance:
        li $v1, 0
        j _EndGetObjectNames

    #; Terminate _EndObjectNames method
    _EndGetObjectNames:
        jr $ra

_Init:
    #; $a0  number of elements for the new associative memory size
    #;
    #; $v0 return value of Allocate of AssociativeMemory
    #; $v1 return error code of Allocate of AssociativeMemory

    #; Init
    li $v0, 0
    li $v1, 0

    #; Call associative memory allocate for creating an associative memory instance
    subu $sp, $sp, 4
    sw $ra, 0($sp)
    move $a1, $a0
    li $a0, -1
    jal AssociativeMemory #; $v0, $v1 already have correct return values from associativeMemory method
    lw $ra, 0($sp)
    addu $sp, $sp, 4

    #; Terminate _Init method
    _EndInit:
        jr $ra

_CreateObject:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #;
    #; $v0  0 ok
    #;      1 object name has already been taken

    #; Init
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    #; Call associative memory create for creating a new key/element association
    _CreateObjectName:
    subu $sp, $sp, 8
    sw $a1, 4($sp)
    sw $a0, 0($sp)
    move $a2, $a1
    move $a1, $a0
    li $a0, 2
    jal AssociativeMemory #; $v0, $v1 already have correct return values from associative memory method
    #; Check object creation error codes
    move $t0, $zero
    beq $t0, $v1, _CreateAssMemForObject    #; no error, go on
    addi $t0, 1
    beq $t0, $v1, _ObjectNameAlreadyTaken   #; object name has already been taken
    addi $t0, 1
    beq $t0, $v1, _NoSpaceInLibraryAssMem   #; there's no more space for another object in library associative memory
    addu $sp, $sp, 8
    j _EndCreateObject

    #; Call _Init method for creating an associative memory instance for the new object created
    _CreateAssMemForObject:
    li $a0, 8 #; default max number of object keys
    jal _Init

    #; Call associative memory for setting the newly created associative memory to the value of the object name element
    #; of the library associative memory
    _SetAssMemForObject:
    li $a0, 1
    lw $a1, 0($sp)
    lw $a2, 4($sp)
    addu $sp, $sp, 8
    move $a3, $v0  #; _Init return value to associativeMemory $a3 param
    jal AssociativeMemory
    li $v0, 0 #; no error code
    j _EndCreateObject

    #; Called if object name has already been taken
    _ObjectNameAlreadyTaken:
        li $v1, 1
        addu $sp, $sp, 8
        j _EndCreateObject
    _NoSpaceInLibraryAssMem:
        #; Get object library instance associative memory size to allocate a new one
        lw $t7, 0($sp) #; get object library instance (no stack change because it's useless here)
        lw $t0, 8($t7) #; get size
        addi $t0, 8 #; default increment of size
        li $a0, -1
        move $a1, $t0
        jal AssociativeMemory
        #; Call copy associative memory to copy old objects to the new memory
        li $a0, 4
        lw $t7, 0($sp) #; (no stack change because it's useless here)
        move $a1, $t7
        move $a2, $v0   #; $v0 holds the new ass.mem. just created
        subu $sp, $sp, 4
        sw $v0, 0($sp)  #; save the new ass.mem. just created
        jal AssociativeMemory
        lw $t7, 4($sp)
        lw $t6, 0($sp)
        addu $sp, $sp, 8
        lw $t0, 0($t6)  #; overwrite old ass.mem. infos with the new one expanded
        sw $t0, 0($t7)
        lw $t0, 4($t6)
        sw $t0, 4($t7)
        lw $t0, 8($t6)
        sw $t0, 8($t7)
        #; Call itself to finally create object
        move $a0, $t7
        lw $a1, 0($sp)
        addu $sp, $sp, 4
        jal _CreateObject

        j _EndCreateObject

    #; Terminate _CreateObject method
    _EndCreateObject:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra
    
_AddKey:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #; $a2  string buffer of property name
    #;
    #; $v0  0 ok
    #;      1 object doesn't exist
    #;      2 object property name has already been taken

    #; Init
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    #; Get associative memory of the specified object in library associative memory instance
    subu $sp, $sp, 12
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    move $t7, $v0 #; $t7 will now hold object properties associative memory
    bne $v1, $zero, _AddKeyObjectDontExist #; check get AssociativeMemory error code

    #; Call create of associative memory
    lw $a2, 0($sp)  #; reload correct property name of object (no stack change because it's useless here)
    subu $sp, $sp, 4
    sw $t7, 0($sp)  #; save object properties associative memory
    li $a0, 2
    move $a1, $t7   #; associative memory instance return value of previous jal AssociativeMemory
    move $a3, $zero #; DEFAULT, new property has value of 0 (zero)
    jal AssociativeMemory
    li $t0, 1       #; check create associativeMemory error code
    beq $t0, $v1, _PropertyNameAlreadyTaken
    addi $t0, 1
    beq $t0, $v1, _NoSpaceInObjectProperties
    li $v0, 0       #; no error then set error code to 0 (zero)
    addu $sp, $sp, 16 #; delete object properties associative memory from stack
    j _EndAddKey

    #; Called if passed object name don't match with any stored in library associative memory keys
    _AddKeyObjectDontExist:
        li $v1, 1
        addu $sp, $sp, 12
        j _EndAddKey
    #; Called if passed property name has already been taken
    _PropertyNameAlreadyTaken:
        li $v1, 2
        addu $sp, $sp, 16
        j _EndAddKey
    #; Called if there's no more space in object properties associative memory for another property
    _NoSpaceInObjectProperties:
        #; Get object properties associative memory size to allocate a new one
        lw $t7, 0($sp)
        lw $t0, 8($t7)
        addi $t0, 8 #; default increment of size
        li $a0, -1
        move $a1, $t0
        jal AssociativeMemory
        #; Call copy associative memory to copy old properties to the new memory
        li $a0, 4
        lw $t7, 0($sp)
        move $a1, $t7
        move $a2, $v0 #; $v0 holds the new ass.mem. just created
        subu $sp, $sp, 4
        sw $v0, 0($sp)
        jal AssociativeMemory
        #; Sets the new properties memory over the old one
        lw $t7, 4($sp)
        lw $t6, 0($sp)
        addu $sp, $sp, 8
        lw $t0, 0($t6)
        sw $t0, 0($t7)
        lw $t0, 4($t6)
        sw $t0, 4($t7)
        lw $t0, 8($t6)
        sw $t0, 8($t7)
        #; Call itself to finally add key
        lw $a0, 8($sp) #; object library instance
        lw $a1, 4($sp)  #; object string name
        lw $a2, 0($sp)  #; property string name
        addu $sp, $sp, 12
        jal _AddKey

        j _EndAddKey

    #; Terminate _AddKey method
    _EndAddKey:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_DeleteKey:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #; $a2  string buffer of property name
    #;
    #; $v0  0 ok
    #;      1 object doesn't exist
    #;      2 object property name doesn't exist

    #; Init
    subu $sp, $sp, 8
    sw $ra, 4($sp)
    sw $a2, 0($sp)

    #; Get associative memory of the specified object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _DeleteKeyObjectDontExist #; check get AssociativeMemory error code

    #; Call delete of associative memory
    lw $a2, 0($sp)  #; reload correct property name of object
    addu $sp, $sp, 4
    li $a0, 3
    move $a1, $v0   #; associative memory instance return value of previous jal AssociativeMemory
    jal AssociativeMemory
    bne $v1, $zero, _PropertyNameDoesntExist
    li $v0, 0       #; no error then set error code to 0 (zero)
    j _EndAddKey

    #; Called if passed object name don't match with any stored in library associative memory keys
    _DeleteKeyObjectDontExist:
        li $v0, 1
        addu $sp, $sp, 4
        j _EndDeleteKey
    #; Called if passed property name has already been taken
    _PropertyNameDoesntExist:
        li $v0, 2
        j _EndDeleteKey
    #; Terminate _DeleteKey method
    _EndDeleteKey:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_SetKeyValue:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #; $a2  string buffer of property name
    #; $a3  value
    #;
    #; $v0  0 ok
    #;      1 object doesn't exist
    #;      2 object property doesn't exist

    #; Init
    subu $sp, $sp, 20
    sw $ra, 16($sp)
    sw $a0, 12($sp)
    sw $a1, 8($sp)
    sw $a2, 4($sp)
    sw $a3, 0($sp)

    #; Get associative memory of the specified object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _SetKeyObjectDontExist #; check get AssociativeMemory error code

    #; Call set of associative memory
    lw $a2, 4($sp)  #; reload correct property name of object
    lw $a3, 0($sp)  #; reload correct value
    addu $sp, $sp, 8
    li $a0, 1
    move $a1, $v0   #; associative memory instance return value of precedent jal AssociativeMemory
    jal AssociativeMemory
    bne $v1, $zero, _SetKeyPropertyDontExist #; check create associativeMemory error code
    li $v0, 0       #; no error then set error code to 0 (zero)
    addu $sp, $sp, 8
    j _EndSetKeyValue

    #; Called if passed object name don't match with any stored in library associative memory keys
    _SetKeyObjectDontExist:
        li $v0, 1
        addu $sp, $sp, 16
        j _EndSetKeyValue
    #; Called if passed property name has already been taken
    _SetKeyPropertyDontExist:
        li $v0, 2
        addu $sp, $sp, 8
        j _EndSetKeyValue
    #; Terminate _SetKeyValue method
    _EndSetKeyValue:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_GetKeyValue:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #; $a2  string buffer of property name
    #;
    #; $v0  property value
    #; $v1  0 ok
    #;      1 object doesn't exist
    #;      2 object property doesn't exist

    #; Init
    li $v0, 0
    subu $sp, $sp, 16
    sw $ra, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)

    #; Get associative memory of the specified object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _GetKeyObjectDontExist #; check get AssociativeMemory error code

    #; Call set of associative memory
    lw $a2, 0($sp)  #; reload correct property name of object
    addu $sp, $sp, 4
    move $a0, $zero
    move $a1, $v0   #; associative memory instance return value of precedent jal AssociativeMemory
    jal AssociativeMemory #; $v0 will hold return value
    bne $v1, $zero, _GetKeyPropertyDontExist #; check create associativeMemory error code
    li $v1, 0       #; no error then set error code to 0 (zero)
    addu $sp, $sp, 8
    j _EndGetKeyValue

    #; Called if passed object name don't match with any stored in library associative memory keys
    _GetKeyObjectDontExist:
        li $v1, 1
        addu $sp, $sp, 12
        j _EndGetKeyValue
    #; Called if passed property name has already been taken
    _GetKeyPropertyDontExist:
        li $v1, 2
        addu $sp, $sp, 8
        j _EndGetKeyValue
    #; Terminate _SetKeyValue method
    _EndGetKeyValue:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_CopyObject:
    #; $a0  library associative memory object
    #; $a1  string buffer of origin object name
    #; $a2  string buffer of destination object name
    #;
    #; $v0  0 ok
    #;      1 object origin doesn't exist
    #;      2 object dest doesn't exist

    #; Init
    li $v0, 0
    subu $sp, $sp, 16
    sw $ra, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)

    #; Get associative memory of the origin object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _CopyObjectOriginDontExist #; check get AssociativeMemory error code
    subu $sp, $sp, 4
    sw $v0, 0($sp)

    #; Get associative memory of the destination object in library associative memory instance    
    lw $a0, 12($sp) #; one stack before due to $v0 saved by last ass.mem. call (no stack change because it's useless here)
    lw $a1, 8($sp)
    lw $a2, 4($sp)
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _CopyObjectDestDontExist #; check get AssociativeMemory error code
    subu $sp, $sp, 4
    sw $v0, 0($sp)

    #; Call associative memory for copying origin object ass.mem. (load from last sp) to destination object ass.mem (stored in $v0)
    lw $t0, 4($sp)  #; (no stack change because it's useless here)
    li $a0, 4
    add $a1, $zero, $t0
    add $a2, $zero, $v0
    jal AssociativeMemory
    li $t0, 2
    beq $t0, $v1, _CopyObjectDestTooSmall #; check if destination object has not enough space
    li $v0, 0 #; no error code
    addu $sp, $sp, 20
    j _EndCopyObject

    #; Called if passed object name don't match with any stored in library associative memory keys
    _CopyObjectOriginDontExist:
        li $v0, 1
        addu $sp, $sp, 12
        j _EndCopyObject
    #; Called if passed property name has already been taken
    _CopyObjectDestDontExist:
        li $v0, 2
        addu $sp, $sp, 16       
        j _EndCopyObject
    #; Called if destination object has not enough space to store all origin object elements
    _CopyObjectDestTooSmall:
        #; Get origin and dest object library instance associative memory size to allocate a new one
        lw $t0, 4($sp)  #; origin object ass.mem.
        lw $t1, 0($sp)  #; dest object ass.mem.
        addu $sp, $sp, 4
        sw $t1, 0($sp)
        lw $t2, 8($t0)  #; get right size
        li $a0, -1
        move $a1, $t2
        jal AssociativeMemory
        #; Copy new info to the dest object ass.mem.
        lw $t1, 0($sp)  #; dest object ass.mem.
        addu $sp, $sp, 4
        lw $t7, 0($v0)
        sw $t7, 0($t1)
        lw $t7, 4($v0)
        sw $t7, 4($t1)
        lw $t7, 8($v0)
        sw $t7, 8($t1)
        #; Call itself to finally copy objects
        lw $a0, 8($sp)
        lw $a1, 4($sp)
        lw $a2, 0($sp)
        addu $sp, $sp, 12
        jal _CopyObject

        j _EndCopyObject
    
    #; Terminate _EndCopyObject method
    _EndCopyObject:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_CloneObject:
    #; $a0  library associative memory object
    #; $a1  string buffer of origin object name
    #; $a2  string buffer of destination object name
    #;
    #; $v0  0 ok
    #;      1 object origin doesn't exist
    #;      2 object dest doesn't exist

    #; Init
    li $v0, 0
    subu $sp, $sp, 16
    sw $ra, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)

    #; Get associative memory of the origin object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _CloneObjectOriginDontExist #; check get AssociativeMemory error code

    #; Set associative memory of the destination object as ass.mem. of origin object in library associative memory instance
    lw $a0, 8($sp)
    lw $a2, 0($sp)
    addu $sp, $sp, 12
    move $a3, $v0 #; associative memory of origin object obtained by previous get
    move $a1, $a0
    li $a0, 1
    jal AssociativeMemory
    bne $v1, $zero, _CloneObjectDestDontExist #; check set AssociativeMemory error code

    j _EndCloneObject

    #; Called if passed object name don't match with any stored in library associative memory keys
    _CloneObjectOriginDontExist:
        li $v0, 1
        addu $sp, $sp, 12
        j _EndCloneObject
    #; Called if passed property name has already been taken
    _CloneObjectDestDontExist:
        li $v0, 2
        j _EndCloneObject
    #; Terminate _SetKeyValue method
    _EndCloneObject:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_GetObjectKeys:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #;
    #; $v0  array address of string keys
    #; $v1  0, no array created due to no objects in library
    #;      n, size of array created or specified object don't exist

    #; Init
    li $v0, 0
    li $v1, 0
    subu $sp, $sp, 4
    sw $ra, 0($sp)

    #; Get associative memory of the specified object in library associative memory instance
    move $a2, $a1
    move $a1, $a0
    move $a0, $zero
    jal AssociativeMemory
    bne $v1, $zero, _GetObjectKeysObjectDontExist #; check get AssociativeMemory error code

    move $a0, $v0 #; AssociativeMemory return value to input of _GetObjectKeys
    jal _GetObjectNames #; $v0 will already hold the correct array address created
    j _EndGetObjectKeys

    #; Called if passed object name don't match with any stored in library associative memory keys    
    _GetObjectKeysObjectDontExist:
        li $v1, 0
        j _EndGetObjectKeys

    #; Terminate _GetObjectKeys method
    _EndGetObjectKeys:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra

_DeleteObject:
    #; $a0  library associative memory object
    #; $a1  string buffer of object name
    #;
    #; $v0  0 ok
    #;      1 object doesn't exist

    #; Init
    subu $sp, $sp, 4
    sw $ra, 4($sp)

    #; Call delete of associative memory
    move $a2, $a1
    move $a1, $a0
    li $a0, 3
    jal AssociativeMemory
    bne $v1, $zero, _DeleteObjectNameDoesntExist
    li $v0, 0       #; no error then set error code to 0 (zero)
    j _EndDeleteObject

    #; Called if passed object name don't match with any stored in library associative memory keys
    _DeleteObjectNameDoesntExist:
        li $v0, 1
        j _EndDeleteObject

    #; Terminate _DeleteObject method
    _EndDeleteObject:
        lw $ra, 0($sp)
        addu $sp, $sp, 4
        jr $ra