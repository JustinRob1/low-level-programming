#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2022 <Justin Robertson>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#------------------------------------------------------------------------------
# CCID: jtrober1                 
# Lecture Section: A1
# Instructor: Matthew Gaudet     
# Lab Section: D09        
# Teaching Assistants: Islam Ali, Mostafa Yadegari 
#-----------------------------------------------------------------------------

.include "test.s"

.data
hashTable:   .space  512
internArray: .space  512

.text
#------------------------------------------------------------------------------
# internString
# Performs interning of the mutable string that is inputted
# 
# Arguments:
#   a0: address of a mutable string
#
# Returns:
#   a0: interned string identifier
# 
# Register Usage:
#   s0: Stores the address of the mutable string
#   s1: Stores the address of the hash table and node of the linked list
#   s2: Stores the hash code of the string
#   s3: Stores the address of the address of a new node of the linked list
#   s4: Stores the addresses of the strings
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Stores the address of the bucket in the hash table
#-----------------------------------------------------------------------------

internString:
    addi sp, sp, -24 # Make room for 6 item on the stack
    sw   ra, 0(sp)   # Save ra onto the stack
	sw   s0, 4(sp)   # Save s0 onto the stack
    sw   s1, 8(sp)   # Save s1 onto the stack
    sw   s2, 12(sp)  # Save s2 onto the stack
    sw   s3, 16(sp)  # Save s3 onto the stack
    sw   s4, 20(sp)  # Save s4 onto the stack
    mv   s0, a0      # Save the address of mutable string into s0
    jal  hash        # Jump to hash, a0 now contains value of the hash
    mv   s2, a0      # Move the hash code into s2 
    la   t0, hashTable # t0 <- Addr(hashTable)
    slli t1, a0, 2     # t1 <- hash * 4
    add  s1, t1, t0    # s1 <- Addr(hashTable[hash])
    lw   t2, 0(s1)     # t2 <- hashTable[hash]
    beq  t2, zero, zeroString # If the entry is zero then branch to the zeroString label
    # Else there is an entry present
    li     t1, 0x80000000    # t1 <- 0x80000000
    and    t1, t1, t2        # t1 <- bit 31
    beq    t1, zero, nonZero # If bit 31 is zero then an entry is already present, branch to the nonZero label
    # Else bit 31 is set and a linked list has already been created for this bucket
    li     t0, 0x7FFFFFFF # t0 <- 0x7FFFFFFF
    and    s4, t0, t2 # Since bit 1 is set to 1 must flip bit 31 to get the actual address
    mv     a0, s0     # a0 <- Address of mutable string
    lw     a1, 0(s4)  # a1 <- Value of datum
    li     s1, 0      # i <- 0 (counts the number of elements at the hash for the unique index) 
    # Continue looping until a match is found or a null pointer is found 
    linkedListLoop:
        mv    a0, s0  # Load the address of the mutable string into a0
        jal   equals  # Determine if mutable string equals string in linked list
        bne   a0, zero, matchFound # If equals returns 1 then the strings match, jump to matchFound label
        # Else the strings don't match, check the next element in the linked list
        lw    t0, 8(s4)  # t0 <- pointer
        addi  s1, s1, 1  # i <- i + 1
        beq   t0, zero, noMatch # If the pointer is null then break loop, branch to noMatch label
        # Else the pointer is not null  
        mv    s4, t0    # Move the address of the next node into s4
        lw    a1, 0(s4) # Load the address of the string at the next node
        jal   zero, linkedListLoop # Continue the loop

    # A string in the linked list matches the mutable string
    # Return a unique identifier for the entry 
    matchFound:
        lw   a0, 4(s4)   # Load the unique id from the node
        jal  zero, exit  # Jump to the exit 

    # No match for the mutable string has been found in the linked list
    # create an immutable copy of the index, place address of
    # immutable string into linked list and return the unique identifier
    noMatch:
        # Must create a new node for tha string
        li   a0, 12        # Store 12 in a0 (number of bytes for the node)
        li   a7, 9         # a7 <- 9 
        ecall              # a0 now stores the address to the dynamically allocated memory
        mv   s3, a0        # Move address of the node into s3
        sw   a0, 8(s4)     # Store pointer to the new node into the 3rd position of the prior node
        mv   a0, s0        # Move address of mutable string back into a0
        jal  immutableCopy # Jump to immutableCopy table to create immutable copy 
        sw   a0, 0(s3)     # Store the address of the immutable copy into 1st position of the new node
        slli s1, s1, 16    # Shift the position into the upper halfword
        add  a0, s2, s1    # Add the position (in the upper halfword) to the hash code to get the unique id 
        sw   a0, 4(s3)     # Store the unique id into the 2nd position of the node 
        jal  zero, exit    # Jump to exit

    # The entry at the index is zero, create an immutable copy of the index, place address of
    # immutable string into interning table entry and return the unique identifier
    zeroString:
        mv   a0, s0        # Move the address of mutable string back into a0
        jal  immutableCopy # Create immutable copy of string to be interned
        sw   a0, 0(s1)     # Save address of immutable copy into hashtable
        mv   a0, s2        # Move the hash code back into a0
        jal  zero, exit    # Jump to exit label

    # Bit 31 is zero but the entry is non-zero
    nonZero: 
        mv     a0, s0    # a0 <- Address of mutable string
        mv     a1, t2    # a1 <- Address of string in hashtable
        jal    equals    # Determine if mutable string equals string in hashtable
        bne    a0, zero, matchZero # If a0 is not 0 then the strings match, branch to MatchZero
        # Else the strings don't match 
        li     a0, 12    # Store 12 in a0 (number of bytes for the node)
        li     a7, 9     # a7 <- 9 
        ecall            # a0 now stores the address to the dynamically allocated memory
        li    t0, 0x80000000 # t0 <- 0x80000000
        or    t0, t0, a0     # t0 <- flip MSB bit of address to 1
        sw    t0, 0(s1)  # Store address into the hash table bucket
        sw    a1, 0(a0)  # Put entry already in the hashtable into the linked list
        mv    s4, a0     # Move address of linked list into s4
        sw    s2, 4(s4)  # Store the unique id of the string into the second position of the node
        li    a0, 12     # Store 12 in a0 (number of bytes for the node)
        li    a7, 9      # a7 <- 9 
        ecall            # a0 now stores the address to the dynamically allocated memory
        sw    a0, 8(s4)  # Store the pointer to the next node into the 3rd position of the prior node of the linked list
        mv    s3, a0     # Move the address of the new node into s3
        mv    a0, s0     # Move address of mutable string back into a0
        jal   immutableCopy  # Jump to immutableCopy label to create immutable copy
        sw    a0, 0(s3)   # Store the address of the immutable copy into the first position of the next node
        li    t0, 0x10000 # t0 <- 0x10000
        add   s2, s2, t0  # Put 1 into the upper half word of the unique id since this new string is the 2nd 
                          # string in the current hash bucket
        sw    s2, 4(s3)   # Store the unique id into the 2nd position of the node
        mv    a0, s2      # Move the unique id back into a0
        jal   zero, exit  # Jump to exit 

        # The strings match, reutrn the unique id
        matchZero:
            mv   a0, s2      # Move the unique id back into a0 (Return unique id)
            jal  zero, exit  # Jump to the exit 

    # Restore stack and return to caller
    exit:
        lw     ra, 0(sp)   # Restore ra
        lw     s0, 4(sp)   # Restore s0
        lw     s1, 8(sp)   # Restore s1
        lw     s2, 12(sp)  # Restore s2
        lw     s3, 16(sp)  # Restore s3
        lw     s4, 20(sp)  # Restore s4
        addi   sp, sp, 24  # Restore stack pointer
        jalr   zero, ra, 0 # Return to caller

#------------------------------------------------------------------------------
# equals
# This function checks if 2 strings are entirely equal.
# 
# Args:
#   a0: pointer to string 1
#   a1: pointer to string 2
#
# Returns:
#   a0: 1 if both strings are entirely equal, 0 if not.
# 
# Register Usage:
#   t0: Stores the characters of the string stored at a0
#   t1: Stores the characters of the string stored at a1
#   
#-----------------------------------------------------------------------------
equals:
    # Iterate through ever character in the string stored at the address a0
    # and every character in the string stored at the address a1
    # Each character is compared to each other and if the characters are identical
    # we continue the loop. If the characters are not equal then the loop will branch
    # to the notEquals label
    equalsLoop:
        lbu     t0, 0(a0)    # t0 <- a0[i]
        lbu     t1, 0(a1)    # t1 <- a1[i]
        bne     t0, t1, notEquals # If t0 != t1 then branch to notEquals label
        addi    a0, a0, 1    # a0 <- a0 + 1 (get the address of the next character in the string)
        addi    a1, a1, 1    # a1 <- a1 + 1 (get the address of the next character in the string)
        bne     t1, zero, equalsLoop # Continue the loop if the current character in t1 is not 00
    # If the loop ends, that means that each character of the two strings are equal, return 1
    li      a0, 1       # Return 1 in a0
    jalr    zero, ra, 0 # Return to caller
    
    # The characters at the current index of the two strings are not equal, therefore the strings
    # are not equal, return 0
    notEquals:
        li      a0, 0       # Return 0 in a0
        jalr    zero, ra, 0 # Return to caller

#------------------------------------------------------------------------------
# immutableCopy
# Dynamically allocated space to store immutable copy 
# 
# Arguments:
#   a0: address of a mutable string
#
# Returns:
#   a0: address to immutable copy of string
# 
# Register Usage:
#   t0: Stores the value of i for the loops
#   t1: Stores the bytes of the hashtable
#   t2: Stores the address of the dynamically allocated memory
#   t3: Stores the address of mutable string
#-----------------------------------------------------------------------------

immutableCopy:
    li      t0, 0 # t0 <- i
    # Itearte through ever character in the mutable string to count
    # the number of characters (i represents the number of characters) in the string in 
    # order to find the number of bytes needed
    countLoop:
        add  t1, a0, t0 # t1 <- Addr(string)
        lbu  t1, 0(t1)  # t1 <- char
        beq  t1, zero, finishLoop # Exit loop if char == '\0'
        addi t0, t0, 1  # i <- i + 1
        jal  zero, countLoop  # Next iteration of loop
    
    # The number char has been encountered, now copy all the chars into the allocated space
    finishLoop:
        addi t0, t0, 1  # Add 1 more to t0 in order to store the null byte
        mv   t3, a0  # Save the address of string since its going to get overwritten
        mv   a0, t0  # Move the number of bytes needed into a0
        li   a7, 9   # a7 <- 9
        ecall        # Allocate dynamic memory, a0 now stores the address to the 
        # newly dynamically allocated memory 

        li      t0, 0  # t0 <- i
        # Copy all the elements from mutable string into the dynamically allocated
        # space until null character is encountered
        copyLoop:
            add  t1, t3, t0 # t1 <- Addr(string[i])
            lbu  t1, 0(t1)  # t1 <- string[i]
            beq  t1, zero, copyExit # Exit loop if char == '\0'
            add  t2, a0, t0 # t2 <- Addr(imm_copy[i])
            sb   t1, 0(t2)  # Addr(imm_copy[i]) <- string[i]
            addi t0, t0, 1  # i < i + 1
            jal  zero, copyLoop # Next iteration of loop

        # The immutable copy has been created, return to caller
        copyExit:
            li     t1, 0x00    # t0 <- 0x00 (null char)
            add    t2, a0, t0  # t2 <- Addr of dynamically allocated space
            sb     t1, 0(t2)   # Store null byte to indicate the end of the string 
            jalr   zero, ra, 0 # Return to caller

#------------------------------------------------------------------------------
# getInternedString
# Determines the string address of the immutable string was previously interned or not
# 
# Arguments:
#   a0: interned string identifier
#
# Returns:
#   a0: String address in immutable memory; if string was interned previously or 0 if 
#       string was not interned previously.
# 
# Register Usage:
#   t0: Stores the value from the address
#   t1: Stores bit 31 and the string identifier in the linked list
#   t2: Stores the pointers of the linked list
#   s0: Stores the string identifier
#   s1: Stores the address of the hashtable at the hash
#-----------------------------------------------------------------------------

getInternedString:
    addi sp, sp, -8    # Make room for 2 items on the stack
	sw   s0, 0(sp)     # Save ra onto the stack
    sw   s1, 4(sp)     # Save s1 onto the stack
    mv   s0, a0        # Save the full string identifier into s0
    li   t0, 0xFFFF    # t0 <- 0xFFFF
    and  a0, a0, t0    # Get the lower halfword of the string identifier
    la   t0, hashTable # t0 <- Addr(hashTable)
    slli t1, a0, 2     # t1 <- hash * 4
    add  s1, t1, t0    # s1 <- Addr(hashTable[hash])
    lw   t2, 0(s1)     # t2 <- hashTable[hash]
    beq  t2, zero, noEntry # If there is no entry present at the hash then branch to noEntry label
    # Else an entry is present
    li   t1, 0x80000000    # t1 <- 0x80000000
    and  t1, t1, t2        # t1 <- bit 31
    beq  t1, zero, singleEntry # If bit 31 is zero then there is a single entry, no linked list is created
    # Else bit 31 is 1, a linked list has already been created, search the linked list for the string identifier
    li     t0, 0x7FFFFFFF # t0 <- 0x7FFFFFFF
    and    t0, t0, t2 # Since bit 1 is set to 1 must flip bit 31 to get the actual address
    # Continue looping until a match is found or a null pointer is found 
    entryLoop:
        lw    t1, 4(t0)  # Load the string identifier of the entry in the linked list
        beq   t1, s0, entryMatch # If the string identifier in the linked list matches the one in s0 then the string
                                 # has been previously interned, branch to entry match
        # Else the identifiers don't match, check the next node in the linked list
        lw    t2, 8(t0)  # t2 <- pointer
        beq   t2, zero, noEntry # If the pointer is null then break loop, the string hasn't been interned yet, branch to noEntry label
        # Else the pointer is not null, check the next node in the linked list  
        mv    t0, t2    # Move the address of next bucket into t0
        jal   zero, entryLoop # Continue the loop

    # There is no entry identifier that matches the string identifier, return 0
    noEntry:
        li  a0, 0  # a0 <- 0
        jal zero, internedExit # Jump to exit

    # There is only a single entry present at the hash, check if the string identifer is equal to the hash
    singleEntry:
        bne  s0, a0, noEntry # If the hash code is not the same at the string identifier then the string
                             # has not been previously interned, branch to noEntry
        # Else the string identifier matches the hash code, return address of the only string in the hash
        mv   a0, t2      # Move the address of the immutable copy into a0
        jal zero, internedExit # Jump to exit

    # The string has been previously interned, return the address of the immutable copy of the string
    entryMatch:
        lw  a0, 0(t0) # Load the address of the immutable copy into a0
        jal zero, internedExit # Jump to exit

    # Restore registers and return to caller
    internedExit:
        lw     s0, 0(sp)   # Restore s0
        lw     s1, 4(sp)   # Restore s1
        addi   sp, sp, 8   # Restore stack pointer
        jalr   zero, ra, 0 # Return to caller

#------------------------------------------------------------------------------
# internFile
# Takes in a pointer to a file and interns all the strings in the file and then returns
# a pointer to an array containing all the unique identifiers in the same order as the file 
# as well as the number of unique identifiers
# 
# Arguments:
#   a0: pointer to a file in mutable memory
#
# Returns:
#   a0: a pointer to an array of interned-string identifiers representing each string that 
#        appears in the file in the same order that they appear.
#   a1: An integer value representing the number of identifiers in the list.
# 
# Register Usage:
#   s0: Stores the counter for the loop i
#   s1: Stores the number of string identifiers in the file
#   s2: Stores the file
#   s3: Stores the EOT character (0x20)
#   s4: Stores the space character (0x00)
#   s5: Stores the line feed character (0x0A)
#   s6: Stores the flag for checking if a space or line feed is repeated
#   s7: Stores the file
#   s8: Stores the address of the internArray
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#-----------------------------------------------------------------------------
internFile:
    addi sp, sp, -40 # Make room for 10 item on the stack
    sw   ra, 0(sp)   # Save s0 onto the stack
	sw   s0, 4(sp)   # Save ra onto the stack
    sw   s1, 8(sp)   # Save s1 onto the stack
    sw   s2, 12(sp)  # Save s2 onto the stack
    sw   s3, 16(sp)  # Save s3 onto the stack
    sw   s4, 20(sp)  # Save s4 onto the stack
    sw   s5, 24(sp)  # Save s5 onto the stack
    sw   s6, 28(sp)  # Save s6 onto the stack
    sw   s7, 32(sp)  # Save s7 onto the stack
    sw   s8, 36(sp)  # Save s8 onto the stack

    li  s0, 0  # i <- 0
    li  s1, 0  # Number of string identifers
    mv  s2, a0 # Move file into s2
    li  s3, 0x04 # s3 <- 0x04 (EOT character)
    li  s4, 0x20 # s4 <- 0x20 (space character)
    li  s5, 0x0A # s5 <- 0x0A (line feed character)
    li  s6, 0    # Flag to check for multiple space or line feed chars in a row
    mv  s7, a0   # Move file into s7
    la  s8, internArray # s8 <- internArray
    # Loop through all the characters in the file, dynamically allocating space for each string, call internString
    # and then add to the string identifier to the array. Continue until EOT character is encountered.
    # s2 moves along each string, s7 points to the beginning of the string, so when a string is interned, s7 is 
    # moved to point to the start of the next new string.
    fileLoop:
        lbu  t0, 0(s2)   # t0 <- s0[i]
        beq  t0, s3, EOT # If the char is an EOT char then branch to EOT label
        beq  t0, s4, checkChar # If the current character is an space char then branch to checkChar label
        beq  t0, s5, checkChar # If the current character is a line feed char then branch to checkChar label
        # Else the char is apart of a string
        bne  s6, zero, setAddr # If the flag is 1 then it is the start of a new string, branch to setAddr label
        addi s2, s2, 1 # Increment the address by 1 to get the next byte 
        addi s0, s0, 1 # i <- i + 1
        jal  zero, fileLoop # Continue the loop

    # A space of line feed char has been encountered, determine if it came before another 
    # space or line feed char or if a string needs to be split  
    checkChar:
        bne  s6, zero, skipChar # Branch to skip char label if flag equals 1
        # Else the flag is zero, meaning the previous char was a valid character
        addi s0, s0, 1  # Add 1 for the null byte
        mv   a0, s0     # Move the number of bytes into a0
        li   a7, 9      # a7 <- 9
        ecall  # Allocate dynamic memory, a0 now stores the address to the 
        # newly dynamically allocated memory
        li   t0, 0  # t0 <- i
        addi s0, s0, -1 # Subtract 1 from s0 to get the number of bytes in the string
        # Copy all the elements from the current string into the dynamically allocated
        # space until null character is encountered
        fileCopyLoop:
            add  t1, s7, t0 # t1 <- Addr(string[i])
            lbu  t1, 0(t1)  # t1 <- string[i]
            add  t2, a0, t0 # t2 <- Addr of dynamically allocated space
            sb   t1, 0(t2)  # Store char of string into dynamically allocated space
            addi t0, t0, 1  # i < i + 1
            blt  t0, s0 fileCopyLoop # Continue loop as long as i < # of chars in string
        li   t1, 0x00   # t1 <- 0x00 (null char)
        add  t2, a0, t0 # t2 <- Addr of dynamically allocated space
        sb   t1, 0(t2)  # Store the null byte into the string
        jal  internString   # Get the string identifier of the string
        slli t0, s1, 2      # t0 <- i * 4
        add  t0, s8, t0     # t0 <- Addr(internArray[i])
        sw   a0, 0(t0)      # internArray[i] <- string identifier
        addi s1, s1, 1  # Increment number of identifiers by 1 
        li   s0, 0      # Rest i back to 0
        addi s2, s2, 1  # Increment the address by 1 to get the next byte
        li   s6, 1      # set flag to 1
        jal  zero, fileLoop # Continue the loop
               
        # The previous char was a space of line feed char, skip the char 
        skipChar:
            addi s2, s2, 1 # Increment the address by 1 to get the next byte 
            jal  zero, fileLoop # Continue the loop

        # Move s7 to the first char of the new string
        setAddr:
            mv   s7, s2    # Move the address of s7 to be the start of the new string
            li   s6, 0     # Set the flag to 0
            addi s2, s2, 1 # Increment the address by 1 to get the next byte 
            addi s0, s0, 1 # i <- i + 1
            jal  zero, fileLoop # Continue the loop

        # An EOT char has been encountered, set the return registers and return to caller 
        EOT:
            beq  s6, zero, finishChar # If the flag is 0 that means that the last char of the string is followed by a EOT and the string
            # has not been interned already. Else it is followed by a space or line feed char and all the strings have been interned
            jal  zero, fileExit # Jump to exit
            
        # The last char of the last string is followed by an EOT char, must intern this string
        finishChar:
            addi s0, s0, 1  # Add 1 for the null byte
            mv   a0, s0     # Move the number of bytes into a0
            li   a7, 9   # a7 <- 9
            ecall  # Allocate dynamic memory, a0 now stores the address to the 
            # newly dynamically allocated memory
            li      t0, 0  # t0 <- i
            addi s0, s0, -1 # Subtract 1 from s0 to get the number of bytes in the string
            # Copy all the elements from the current string into the dynamically allocated
            # space until null character is encountered
            finishFileLoop:
                add  t1, s7, t0 # t1 <- Addr(string[i])
                lbu  t1, 0(t1)  # t1 <- string[i]
                add  t2, a0, t0 # t2 <- Addr of dynamically allocated space
                sb   t1, 0(t2)  # Store char of string into dynamically allocated space
                addi t0, t0, 1  # i < i + 1
                blt  t0, s0 finishFileLoop # Continue loop as long as i < # of chars in string
            li   t1, 0x00   # t1 <- 0x00 (null char)
            add  t2, a0, t0 # t2 <- Addr of dynamically allocated space
            sb   t1, 0(t2)  # Store null char into last byte of the dynamically allocated space
            jal  internString   # Get the string identifier of the string
            slli t0, s1, 2      # t0 <- i * 4
            add  t0, s8, t0     # t0 <- Addr(internArray[i])
            sw   a0, 0(t0)      # internArray[i] <- string identifier
            addi s1, s1, 1  # Increment number of identifiers by 1 
            li   s6, 1      # Set flag to 1
            jal  zero, EOT  # Return to EOT

    # Return a0 and a1, restore registers and return to caller
    fileExit:
        mv     a0, s8  # Move pointer to array into a0
        mv     a1, s1  # Move number of string identifiers into a1
        lw     ra, 0(sp)   # Restore ra
        lw     s0, 4(sp)   # Restore s0
        lw     s1, 8(sp)   # Restore s1
        lw     s2, 12(sp)  # Restore s2
        lw     s3, 16(sp)  # Restore s3
        lw     s4, 20(sp)  # Restore s4
        lw     s5, 24(sp)  # Restore s5
        lw     s6, 28(sp)  # Restore s6
        lw     s7, 32(sp)  # Restore s7
        lw     s8, 36(sp)  # Restore s8
        addi   sp, sp, 40  # Restore stack pointer
        jalr   zero, ra, 0 # Return to caller

#------------------------------------------------------------------------------
# hash
# This function hashes a string using a a simple checksum hashing
# 
# Args:
#   a0: pointer to string
#
# Returns:
#   a0: hash of the string
# 
# Register Usage:
#   t0: Stores hash of the string
#   t1: Used to store each character of the string
#   t2: Stores the null character 00
#   t3: Stores n (128)
#-----------------------------------------------------------------------------
hash:
    li      t0, 0   # hash <- 0
    li      t2, 00  # t2 <- 00 (null character)
    li      t3, 128 # n = 128
    # Itearte through ever character in the string stored at the address a0
    # For each character perform the opeartion ((hash + d) % 128)
    # Exit the loop when the null character is reached
    hashLoop:
        lbu     t1, 0(a0)    # t1 <- a0[i]
        beq     t1, t2, exitHash # Branch to exit if the null character is reached
        add     t0, t0, t1   # hash <- hash + d
        rem     t0, t0, t3   # hash <- hash % 128 
        addi    a0, a0, 1    # a0 <- a0 + 1 (get the address of the next character in the string)
        bne     t1, t2, hashLoop # Continue the loop if the current character is not 00
    # The null character has been reached, return the hash in a0
    exitHash:
       mv    a0, t0       # Move the hash into a0
       jalr  zero, ra, 0  # Return to caller