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
# 

.include "common.s"
.text

# --- PART 1A ---


#------------------------------------------------------------------------------
# hash
# This function hashes a string using a modified djb2 algorithm.
# 
# Args:
#   a0: pointer to string
#
# Returns:
#   a0: hash
# 
# Register Usage:
#   t0: Stores the seed
#   t1: Stores the characters of the string
#   t2: Stores the immediate 33; used for multiplcation each iteration
#   t3: Stores the immediate 22900; used for modulo operation each iteartion
#   t4: Stores the null character 00 and 64 for findal modulo operation
#-----------------------------------------------------------------------------
hash:
    li      t0, 5381  # t0 <- 5381
    li      t2, 33    # t2 <- 33
    li      t3, 22900 # t3 <- 22900
    li      t4, 00    # t4 <- 00 (null character)
    # Itearte through ever character in the string stored at the address a0
    # For each character perform the opeartion ((t0 * 33) + t1) % 22900
    # Exit the loop when the null character is reached
    hashLoop:
        lbu     t1, 0(a0)    # t1 <- a0[i]
        beq     t1, t4, exitHash # Branch to exit if the null character is reached
        mul     t0, t0, t2   # t0 <- (t0 * 33)
        add     t0, t0, t1   # t0 <- t0 + t1
        rem     t0, t0, t3   # t0 <- t0 % 22900
        addi    a0, a0, 1    # a0 <- a0 + 1 (get the address of the next character in the string)
        bne     t1, t4, hashLoop # Continue the loop if the current character is not 00
    # The null character has been reached, perform the final modulo operation and return the
    # hash in a0
    exitHash:
        li      t4, 64     # t4 <- 64
        rem     a0, t0, t4 # a0 <- t0 % 64
        ret                 # Return to caller

# --- PART 1B ---

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
#   t2: Stores the null character 00
#   
#-----------------------------------------------------------------------------
equals:
    li      t2, 00  # t2 <- 00 (the null character)
    # Itearte through ever character in the string stored at the address a0
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
        bne     t1, t2, equalsLoop # Continue the loop if the current character in t1 is not 00
    # If the loop ends, that means that each character of the two strings are equal, return 1
    li      a0, 1  # Return 1 in a0
    ret            # Return to caller
    # The characters at the current index of the two strings are not equal, therefore the strings
    # are not equal, return 0
    notEquals:
        li      a0, 0  # Return 0 in a0
        ret            # Return to caller


# --- PART 2 ---

#------------------------------------------------------------------------------
# insert
# This function inserts a key/value pair into a hash table, assuming no 
# collisions.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#   a2: value
#
# Returns:
#   no return value
# 
# Register Usage:
#   s0: Stores the pointer to the hash table
#   t1: Stores the address of the index of the storearray for the key and value to be stored
#       and immediate 0
#    
#-----------------------------------------------------------------------------
insert:
    addi    sp, sp, -8 # Make room for two registers
    sw      ra, 4(sp)  # Save ra on stack
    sw      s0, 0(sp)  # Save s0 on stack
    # The pointer to the hash table must be stored at an another register
    # since the value is going to change when the hash function is called
    mv      s0, a0     # Store the pointer to hash table at s0
    # We must store the pointer to the string to a0 since the hash
    # function requires that the pointer must be at a0
    mv      a0, a1     # Store the pointer to the string at a0
    jal     hash       # The hash of the function is now stored at a0
    li      t1, 2      # t1 <- 2
    mul     a0, a0, t1 # a0 <- a0 * 2
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
	sw 		a1, 0(t1)  # t1[i] <- a1 (Store the pointer to the string at the index t1)
    addi 	a0, a0, 1  # i <- i + 1
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
	sw 		a2, 0(t1)  # t1[i] <- a2 (Store the pointer to the value at the index t1 + 1)
    lw      ra, 4(sp)  # Restore ra from stack
    lw      s0, 0(sp)  # Restore s0 from stack
    addi    sp, sp, 8  # Restore stack pointer
    ret                # Return to caller
 

#------------------------------------------------------------------------------
# find
# This function returns the value for a given key in a hash table, assuming no
# collisions.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#
# Returns:
#   a0: value, -1 if not found
# 
# Register Usage:
#   s0: Stores the pointer to the hash table
#   s1: Stores the index of the key
#   t0: Acts as a temporary variable that stores addresses and immediates
#-----------------------------------------------------------------------------
find:
    addi    sp, sp, -12 # Make room for 3 registers
    sw      ra, 8(sp)   # Save ra on stack
    sw      s0, 4(sp)   # Save s0 on stack
    sw      s1, 0(sp)   # Save s1 on stack 
    mv      s0, a0      # s0 stores the pointer to the hash table
    # a0 must store the pointer to the key for the hash function to work 
    mv      a0, a1     # Set a0 to the pointer to the key
    jal     hash       # The hash of the function is now stored at a0
    li      t0, 2      # t0 <- 2
    mul     a0, a0, t0 # a0 <- a0 * 2
    slli 	t0, a0, 2  # t0 <- i * 4
    add 	t0, t0, s0 # t0 <- Addr(s0[i])
    mv      s1, a0     # Set s1 to the index of the key
	lw 		a0, 0(t0)  # a0 <- t0[i] (Store the pointer to the string at the index t0)
    li      t0, 00     # t0 <- 00
    beq     a0, t0, notExists # If the key stored at the index doesn't exist then branch to the notExists label
    jal     equals     # Branch to equals label to check if the key stored at the index equals the pointer to the key
    li      t0, 0      # t0 <- 0
    beq     a0, t0, notExists # If a0 stores the value of 0, that means that the equals function returned 0, indicating
    # that the two strings are not equal

    # If the program doesn't branch to the notExists label then the two strings must match, return the key's value
    addi 	s1, s1, 1   # i <- i + 1 (Incremdent i by 1 to get the value of the key)
    slli 	t0, s1, 2   # t0 <- i * 4
    add 	t0, t0, s0  # t0 <- Addr(s0[i])
	lw 		a0, 0(t0)   # a0 <- t0[i] Returns the key's value
    lw      ra, 8(sp)   # Restore ra from stack
    lw      s0, 4(sp)   # Restore s0 from stack
    lw      s1, 0(sp)   # Restore s1 from stack
    addi    sp, sp, 12  # Restore stack pointer
    ret                 # return to caller

    # If the key/value pair doesn’t exist or if the keys don’t match, return -1
    notExists:
        li      a0, -1      # Return -1
        lw      ra, 8(sp)   # Restore ra from stack
        lw      s0, 4(sp)   # Restore s0 from stack
        lw      s1, 0(sp)   # Restore s1 from stack
        addi    sp, sp, 12  # Restore stack pointer
        ret                 # Return to caller


#------------------------------------------------------------------------------
# delete
# This function deletes a key/value pair from a hash table, assuming no
# collisions.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#
# Returns:
#   a0: 0 if the key/value pair was found and deleted, -1 if not
# 
# Register Usage:
#   t0: Acts as a temporary variable that stores addresses and immediates
#   t1: Stores the address of the key and its value
#   s0: stores the pointer to the hash table
#-----------------------------------------------------------------------------
delete:
    addi    sp, sp, -12 # Make room for three registers
    sw      ra, 8(sp)  # Save ra on stack
    sw      s1, 4(sp)  # Save s1 on stack
    sw      s0, 0(sp)  # Save s0 on stack
    mv      s0, a0     # Save the pointer to hash table to s0
    mv      s1, a1     # Save the pointer to the key to s1
    jal     find       # Jump to find function to determine if the key exists in the hash table and/or exists in
                       # the hash table
    li      t0, -1     # t0 <- -1
    beq     a0, t0, delNot # If the function find returns -1 then the value does not exist
    # or the value keys don't match, branch to delNot and return -1
    # Else the keys match so insert 0 as the key and the value
    mv      a0, s1     # Save the pointer to key to a0 (The hash function requires a0 to have the pointer to the string
    jal     hash       # Find the hash of the key
    li      t0, 0      # t0 <- 0
    li      t1, 2      # t1 <- 2
    mul     a0, a0, t1 # a0 <- a0 * 2
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
	sw 		t0, 0(t1)  # t1[i] <- 0 (Store 0 at the key's index)
    addi 	a0, a0, 1  # i <- i + 1
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
	sw 		t0, 0(t1)  # t1[i] <-  (Store the 0 at the value's index)
    li      a0, 0      # a0 <- 0 (return 0)
    lw      ra, 8(sp)  # Restore ra from stack
    lw      s1, 4(sp)  # Restore s1 from stack
    lw      s0, 0(sp)  # Restore s0 from stack
    addi    sp, sp, 12 # Restore stack pointer
    ret                # Return to caller

    # If the key/value pair doesn’t exist or if the keys don’t match, return -1
    delNot:
        li      a0, -1     # Return -1
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller

# --- PART 3 ---


#------------------------------------------------------------------------------
# insert_col
# This function inserts a key/value pair into a hash table.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#   a2: value
#
# Returns:
#   no return value
# 
# Register Usage:
#   t0: Acts as a temporary variable that stores addresses, loop counters and immediates
#   t1: Stores the addresses of the key/value pairs
#   t2: Stores the value of next*
#   s0: stores the pointer to the hash table
#   s1: Stores the indices of the key/value hash 
#-----------------------------------------------------------------------------
insert_col:
    addi    sp, sp, -12 # Make room for three registers
    sw      ra, 8(sp)  # Save ra on stack
    sw      s1, 4(sp)  # Save s1 on stack
    sw      s0, 0(sp)  # Save s0 on stack
    # The pointer to the hash table must be stored at an another register
    # since the value is going to change when the hash function is called
    mv      s0, a0     # Store the pointer to hash table at s0
    # We must store the pointer to the string to a0 since the hash
    # function requires that the pointer must be at a0
    mv      a0, a1     # Store the pointer to the string at a0
    jal     hash       # The hash of the function is now stored at a0
    li      s1, 3      # s1 <- 3
    mul     a0, a0, s1 # a0 <- a0 * 3
    mv      s1, a0     # Save the index of the hash into s3
    slli 	s1, a0, 2  # s1 <- i * 4
    add 	s1, s1, s0 # s1 <- Addr(s0[i])
    lw      t2, 0(s1)  # Load next* into t2
    li      t0, 00     # t0 <- 00
    beq     t2, t0, insertEmpty # If the next* pointer is empty then we insert the
                                # key and its value normally
    # Else the hash is not empty so we check if it contains one entry or more
    addi 	a0, a0, 2  # i <- i + 2
    slli 	s1, a0, 2  # s1 <- i * 4
    add 	s1, s1, s0 # s1 <- Addr(s0[i])
    lw      t2, 0(s1)  # Load next* into t2
    # Check the 3rd index of the hash to see if next* is a null pointer or not
    bne     t2, t0, notNull # If next* is not a null pointer then branch to notNull
    # Else next* is a null pointer, allocate a new area in memory and insert the values
    jal     alloc      # Alloc space in memory to store the key/value pair
    sw      a0, 0(s1)  # Store next* into storearray for the given key/value pair
    sw      a1, 0(a0)  # Store the key into index 0 at the space allocated in memory
    li      t0, 1      # i = 1
    slli    t1, t0, 2  # t1 <- i * 4
    add     t1, t1, a0 # t1 <- Addr(a0[i])
    sw      a2, 0(t1)  # Store the value into the index 1 at the space allocated in memory
    lw      ra, 8(sp)  # Restore ra from stack
    lw      s1, 4(sp)  # Restore s1 from stack
    lw      s0, 0(sp)  # Restore s0 from stack
    addi    sp, sp, 12 # Restore stack pointer
    ret                # Return to caller

    # Insert the key/value pair normally since no key/value pair is stored in the hash
    insertEmpty:
        sw 		a1, 0(s1)  # s1[i] <- a1 (Store the pointer to the string at the index s1)
        addi 	a0, a0, 1  # i <- i + 1
        slli 	s1, a0, 2  # s1 <- i * 4
        add 	s1, s1, s0 # s1 <- Addr(s0[i])
        sw 		a2, 0(s1)  # s1[i] <- a2 (Store the pointer to the value at the index s1 + 1)
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller

    # next* is not a null pointer, allocated a new place in memory and store the value
    # Search through the list until the null value has been found
    notNull:
        jal     alloc       # Alloc space in memory to store the key/value pair
        li      t0, 00      # t0 <- 00
        li      t1, 2       # i = 2
        # Iterate through all the next* pointer values until the null pointer is found 
        nullLoop:
            slli 	s1, t1, 2  # s1 <- i * 4
            add 	s1, s1, t2 # s1 <- Addr(t2[i])
            lw      t2, 0(s1)  # Load next* into t2 for the given key/value pair
            bne     t2, t0, nullLoop # If next* is not a null pointer, then it must be pointing to another hash
                                     # continue the loop until we find a hash with a null pointer next*
        sw      a0, 0(s1)  # Store the memory address of the newly allocated key/value pair into the key/value
                           # pair that has a null pointer next*
        sw      a1, 0(a0)  # Store the key into index 0 at the space allocated in memory
        li      t0, 1      # i = 1
        slli    t1, t0, 2  # t1 <- i * 4
        add     t1, t1, a0 # t1 <- Addr(a0[i])
        sw      a2, 0(t1)  # Store the value into the index 1 at the space allocated in memory
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller
        
#------------------------------------------------------------------------------
# find_col
# This function returns the value for a given key in a hash table.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#
# Returns:
#   a0: value, -1 if not found
# 
# Register Usage:
#   s0: Stores the pointer to the hash table
#   s1: Stores the index of the key
#   t0: Acts as a temporary variable that stores addresses and immediates
#   t1: Stores the addresses of the key/value pairs
#   t2: Acts as a temporary variable that stores addresses and immediates
#   t3: Stores the immediate 1
#-----------------------------------------------------------------------------
find_col:
    addi    sp, sp, -12 # Make room for 3 registers
    sw      ra, 8(sp)   # Save ra on stack
    sw      s0, 4(sp)   # Save s0 on stack
    sw      s1, 0(sp)   # Save s1 on stack 
    mv      s0, a0      # s0 stores the pointer to the hash table
    # a0 must store the pointer to the key for the hash function to work 
    mv      a0, a1     # Set a0 to the pointer to the key
    jal     hash       # The hash of the function is now stored at a0
    li      t0, 3      # t0 <- 3
    mul     a0, a0, t0 # a0 <- a0 * 3
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
    mv      s1, a0     # Set s1 to the index of the key
	lw 		a0, 0(t1)  # a0 <- t1[i] (Store the pointer to the string at the index t0)
    li      t0, 00     # t0 <- 00
    beq     a0, t0, notExistsCol # If the key stored at the index is null then branch to the notExists label
    # Else iterate through all the next* pointer values until the null pointer is found 
    li      t3, 1       # t3 <- 1
    nullLoopCol:
        li      t2, 0      # t2 <- 0
        slli 	s1, t2, 2  # s1 <- i * 4
        add 	s1, s1, t1 # s1 <- Addr(t1[i])
        lw      a0, 0(s1)  # a0 <- s1[i]
        jal     equals     # Check to see if the two keys are equal
        beq     a0, t3, foundCol # If the equals function returns 1 then the two keys are equal
        addi    t2, t2, 2  # The two keys are not equal to get the pointer to the next linked list
        slli 	t1, t2, 2  # t1 <- i * 4
        add 	t1, t1, s1 # t1 <- Addr(s1[i])
        lw      t1, 0(t1)  # t1 <- t1[i]
        li      t0, 00     # t0 <- 00
        bne     t1, t0, nullLoopCol # If next* is not a null pointer, then it must be pointing to another hash
                                    # continue the loop until we find a hash with a null pointer next*
    # If the loop exits then we have found the null pointer and the key was not found, return -1
    li      a0, -1      # Return -1
    lw      ra, 8(sp)   # Restore ra from stack
    lw      s0, 4(sp)   # Restore s0 from stack
    lw      s1, 0(sp)   # Restore s1 from stack
    addi    sp, sp, 12  # Restore stack pointer
    ret                 # return to caller

    # If the key/value pair doesn’t exist or if the keys don’t match, return -1
    notExistsCol:
        li      a0, -1      # Return -1
        lw      ra, 8(sp)   # Restore ra from stack
        lw      s0, 4(sp)   # Restore s0 from stack
        lw      s1, 0(sp)   # Restore s1 from stack
        addi    sp, sp, 12  # Restore stack pointer
        ret                 # Return to caller
    
    foundCol:
        addi    t2, t2, 1   # i = i + 1
        slli 	t1, t2, 2   # s1 <- i * 4
        add 	t1, t1, s1  # s1 <- Addr(t2[i])
        lw      a0, 0(t1)   # a0 <- t1[i] (Return the value) 
        lw      ra, 8(sp)   # Restore ra from stack
        lw      s0, 4(sp)   # Restore s0 from stack
        lw      s1, 0(sp)   # Restore s1 from stack
        addi    sp, sp, 12  # Restore stack pointer
        ret                 # Return to caller

#------------------------------------------------------------------------------
# delete_col
# This function deletes a key/value pair from a hash table.
# 
# Args:
#   a0: pointer to hash table (storearray)
#   a1: pointer to key (string)
#
# Returns:
#   a0: 0 if the key/value pair was found and deleted, -1 if not
# 
# Register Usage:
#   s0: Stores the pointer to the hash table
#   s1: Stores the index of the key
#   t0: Acts as a temporary variable that stores addresses and immediates
#   t1: Stores the addresses of the key/value pairs
#   t2: Acts as a temporary variable that stores addresses and immediates
#   t3: Acts as a temporary variable that stores addresses and immediates
#   t4: Acts as a temporary variable that stores addresses and immediates
#   t5: Acts as a temporary variable that stores addresses and immediates
#-----------------------------------------------------------------------------
delete_col:
    addi    sp, sp, -12 # Make room for three registers
    sw      ra, 8(sp)   # Save ra on stack
    sw      s1, 4(sp)   # Save s1 on stack
    sw      s0, 0(sp)   # Save s0 on stack
    mv      s0, a0      # Save the pointer to hash table to s0
    mv      s1, a1      # Save the pointer to the key to s1
    jal     find_col    # Jump to find_col function to determine if the key exists in the hash table and/or exists in
                        # the hash table
    li      t0, -1      # t0 <- -1
    beq     a0, t0, delNotCol # If the function find returns -1 then the value does not exist
    # or the key has not been inserted, return -1
    # Else the key has been inserted
    mv      a0, s1     # Save the pointer to key to a0 (The hash function requires a0 to have the pointer to the string
    jal     hash       # Find the hash of the key
    li      t0, 0      # t0 <- 0
    li      t1, 3      # t1 <- 2
    mul     a0, a0, t1 # a0 <- a0 * 3
    slli 	t1, a0, 2  # t1 <- i * 4
    add 	t1, t1, s0 # t1 <- Addr(s0[i])
    lw      t2, 0(t1)  # t2 <- t1[i]
    beq     t2, s1, keyEquals # If the key we are trying to delete matches the key in the current hash, jump to key equals
    # Else the key is deeper into the linked list so we must search through the list
    li      t0, 00      # t0 <- 00
    # Continue searching through the list until the keys match
    delLoop:
        li      t4, 2      # i = 2
        slli 	t5, t4, 2  # t5 <- i * 4
        add 	t5, t5, t1 # t5 <- Addr(t1[i])
        lw      t3, 0(t5)  # t3 = next*
        lw      t2, 0(t3)  # t2 = key
        beq     t2, s1, replaceNext # If the key matches the one we are trying to delete branch to replaceNext
        mv      t1, t3     # Save next* to t1
        bne     t0, t1, delLoop # If the pointer next* is not null, continue the loop

    # Replaces the next* previous hash to the next* of the key being deleted
    replaceNext:
        li      t0, 2      # i = 2
        slli 	t2, t0, 2  # t2 <- i * 4
        add 	t2, t2, t3 # t2 <- Addr(t3[i]) 
        lw      t3, 0(t2)  # Load the next* from the key we are deleting
        sw      t3, 0(t5)  # Store next* from the string being deleted into the previous hash 
        li      a0, 0      # Return 0
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller   

    # This label is branched to when the key in the hash is the key we are trying to delete
    # Determines if next* is a null pointer or not
    keyEquals:
        addi    a0, a0, 2  # i = 2
        slli 	t1, a0, 2  # t1 <- i * 4
        add 	t1, t1, s0 # t1 <- Addr(s0[i])
        lw      t2, 0(t1)  # Load the next* into t2
        li      t0, 00     # t0 <- 00
        beq     t2, t0, nullPointer # If next* is a null pointer jump to nullPointer
        li      t0, 0      # t0 <- 0
        li      t3, 2      # t3 <- 2
        li      t5, 3      # t5 <- 3
        sub     a0, a0, t3 # i - 2
        slli 	t1, a0, 2  # t1 <- i * 4
        add 	t1, t1, s0 # t1 <- Addr(s0[i])
        # Replaces the key, value and next* of the key/value pair in the hash with the ones its pointing to
        keyLoop:
            slli 	t4, t0, 2  # t4 <- i * 4   
            slli    t3, t0, 2  # t3 <- i * 3
            add 	t4, t4, t2 # t4 <- Addr(t2[i])
            add     t3, t3, t1 # t3 <- Addr(t3[i])
            lw      t4, 0(t4)  # Load each compomenet of the key/value pair
            sw      t4, 0(t3)  # Store the component into the hash
            addi    t0, t0, 1  # i + 1
            bne     t0, t5, keyLoop # Contiune the loop until i = 3
        li      a0, 0      # Return 0
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller   

    # Branched to when the hash is the key being deleted and has a null pointer
    # Inserts 0 into the key and its value
    nullPointer:
        li      t0, 2      # t0 <- 2
        sub     a0, a0, t0 # i = 2 - 2 = 0
        li      t0, 0      # t0 <- 0
        slli 	t1, a0, 2  # t1 <- i * 4
        add 	t1, t1, s0 # t1 <- Addr(s0[i])
        sw      t0, 0(t1)  # Set the key to 0
        addi    a0, a0, 1  # i + 1
        slli 	t1, a0, 2  # t1 <- i * 4
        add 	t1, t1, s0 # t1 <- Addr(s0[i])
        sw 		t0, 0(t1)  # t1[i] <- 0 (Set the value to 0)
        li      a0, 0      # a0 <- 0 (return 0)
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller

    # If the key/value pair doesn’t exist or if the keys don’t match, return -1
    delNotCol:
        li      a0, -1     # Return -1
        lw      ra, 8(sp)  # Restore ra from stack
        lw      s1, 4(sp)  # Restore s1 from stack
        lw      s0, 0(sp)  # Restore s0 from stack
        addi    sp, sp, 12 # Restore stack pointer
        ret                # Return to caller