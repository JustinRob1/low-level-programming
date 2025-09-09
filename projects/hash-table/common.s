#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2022 University of Alberta
# Copyright 2022 Rajan Maghera
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
#
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------
# Lab - Hash Table
#
# Author: Rajan Maghera
# Date: May 26, 2022
#
# This file provides numerous helper functions to run, test, and display a
# student's solution to the hash table lab.
#-------------------------------
#

.data

.align 2 # align to word

# area for fake dynamic memory allocation
alloc_pointer: .space 4 # stores pointer to end of alloc_buffer
alloc_buffer: .space 1024 # space where actual memory goes

# arrays for testing
test_array: .space 768 # 256 words
test_case_array: .space 768 # 256 words

# test inputs for hashing
test_input_1: .asciz "CMPUT 229" # hashes to 23
test_input_2: .asciz "MATH 100" # hashes to 32
test_input_3: .asciz "STAT 151" # hashes to 44
test_input_4: .asciz "ENGL 107" # hashes to 23
test_input_5: .asciz "CMPUT 901" # hashes to 32

# tests for equals functions
test_equals_1:  .asciz "Hello, world."
test_equals_2:  .asciz "HELLO WORLD!"
test_equals_3:  .asciz "Goodnight"
test_equals_4:  .asciz "Hello, world."  

# strings for displaying test output
test_pass: .asciz " [X] Great job!    "
test_fail: .asciz " [ ] Almost there! " 
test_default_running: .asciz "\n\n-- Running tests for part "
test_part1a_running: .asciz "1a: hash --\n"
test_part1b_running: .asciz "1b: equals --\n"
test_part2_insert_running: .asciz "2: insert --\n"
test_part2_find_running: .asciz "2: find --\n"
test_part2_delete_running: .asciz "2: delete --\n"
test_part3_insert_running: .asciz "3: insert_col --\n"
test_part3_find_running: .asciz "3: find_col --\n"
test_part3_delete_running: .asciz "3: delete_col --\n"
test_new_line: .asciz "\n"
test_seperator: .asciz " | "
test_colon: .asciz ": "
test_arrow: .asciz " -> "
test_empty: .asciz "Empty\n"
test_null: .asciz "<NULL>"

.text

#------------------------------------------------------------------------------
# main
# This function runs all test cases for the hash table lab.
# 
# Register Usage:
#   t0: pointer to alloc_pointer for initalization
#   t1: pointer to buffer for initalization
#   s0: pointer to test_case_array
#   s1: pointer to test_array
#   a0-a7: arguments for functions and ecalls
#-----------------------------------------------------------------------------
main:

    # initalize alloc pointer
    la t0, alloc_pointer  # load address to alloc pointer 
    la t1, alloc_buffer # load address to alloc space
    sw t1, 0(t0) # save pointer to alloc space in alloc_pointer

    # save addresses of test arrays, makes it easier later on
    la s1, test_array 
    la s0, test_case_array

    # --- PART 1A TESTS ---

    # print header
    li a7, 4
    la a0, test_default_running
    ecall
    la a0, test_part1a_running
    ecall

    # case 1
    li a0, 0
    la a1, test_input_1
    li a2, 23
    jal test_runner

    # case 2
    li a0, 0
    la a1, test_input_2
    li a2, 32
    jal test_runner

    # case 3
    li a0, 0
    la a1, test_input_3
    li a2, 44
    jal test_runner

    # --- PART 1B TESTS ---

    # print header
    li a7, 4
    la a0, test_default_running
    ecall
    la a0, test_part1b_running
    ecall

    # case 1 -- should not equal
    li a0, 1
    la a1, test_equals_1
    li a2, 0
    la a3, test_equals_2
    jal test_runner

    # case 2 -- should not equal
    li a0, 1
    la a1, test_equals_1
    li a2, 0
    la a3, test_equals_3
    jal test_runner

    # case 3 -- should equal
    li a0, 1
    la a1, test_equals_1
    li a2, 1
    la a3, test_equals_4
    jal test_runner

    # --- PART 2: INSERT TEST ---

    # print header
    li a7, 4
    la a0, test_default_running
    ecall
    la a0, test_part2_insert_running
    ecall

    # case 1
    addi a0, s0, 184 # hash 23
    la a1, test_input_1
    li a2, 154
    li a3, 0
    jal test_add # add to test case array
    li a0, 2
    jal test_runner

    # case 2
    addi a0, s0, 256 # hash 32
    la a1, test_input_2
    li a2, 107
    li a3, 0
    jal test_add # add to test case array
    li a0, 2
    jal test_runner

    # clear arrays
    jal test_clear_arrays

    # case 3
    addi a0, s0, 352 # hash 44
    la a1, test_input_3
    li a2, 99
    li a3, 0
    jal test_add # add to test case array
    li a0, 2
    jal test_runner

    # clear arrays
    jal test_clear_arrays


    # --- PART 2: FIND TEST ---

    # print header
    li a7, 4
    la a0, test_default_running
    ecall
    la a0, test_part2_find_running
    ecall

    # case 1 -- should be found
    addi a0, s1, 184
    la a1, test_input_1
    li a2, 154
    li a3, 0
    jal test_add # add to test case array
    li a0, 4
    jal test_runner

    # case 2 -- should not be found
    li a0, 4
    la a1, test_input_2
    li a2, -1
    jal test_runner

    # case 3 -- should be found
    addi a0, s1, 352
    la a1, test_input_3
    li a2, 99
    li a3, 0
    jal test_add # add to test case array
    li a0, 4
    jal test_runner

    # clear arrays
    jal test_clear_arrays

    # --- PART 2: DELETE TEST ---

    # print header
    li a7, 4
    la a0, test_default_running
    ecall
    la a0, test_part2_delete_running
    ecall

    # case 1 -- should delete
    addi a0, s1, 352
    la a1, test_input_3
    li a2, 154
    li a3, 0
    jal test_add # add to test case array
    li a0, 6
    li a2, 0 
    jal test_runner

    # case 2 -- should not find and not delete
    li a0, 6
    la a1, test_input_2
    li a2, -1
    jal test_runner

    # case 3 -- should delete
    addi a0, s1, 184
    la a1, test_input_1
    li a2, 87
    li a3, 0
    jal test_add # add to test case array
    li a0, 6
    li a2, 0
    jal test_runner
    
    # --- PART 3: INSERT_COL TEST ---

    # print header
    la a0, test_default_running
    ecall
    la a0, test_part3_insert_running
    ecall

    # case 1 -- simple add
    addi a0, s0, 276 # hash 23
    la a1, test_input_1
    li a2, 154
    li a3, 0
    jal test_add
    li a0, 3
    jal test_runner

    # clear test case array 
    la a0, test_case_array
    li a1, 192
    jal test_clear_array
    
    # case 2 -- insert with overflow
    la a0, test_input_4
    li a1, 83
    li a2, 0
    jal test_add_overflow # add overflow value w/ pointer

    mv a3, a0
    addi a0, s0, 276 # hash 23
    la a1, test_input_1
    li a2, 154
    jal test_add # add to test case array

    li a0, 3
    la a1, test_input_4
    li a2, 83
    jal test_runner
    
    # case 3 -- simple add
    addi a0, s0, 384 # hash 32
    la a1, test_input_2
    li a2, 90
    li a3, 0
    jal test_add # add to test case array
    li a0, 3
    jal test_runner

    # clear arrays
    jal test_clear_arrays

    # --- PART 3: FIND_COL TEST ---

    # print header
    la a0, test_default_running
    ecall
    la a0, test_part3_find_running
    ecall

    # insert sample data for all find tests
    la a0, test_input_4 
    li a1, 83
    li a2, 0
    jal test_add_overflow # add to overflow

    mv a3, a0
    addi a0, s1, 276 # hash 23
    la a1, test_input_1 # not in overflow
    li a2, 154
    jal test_add # add to test case array

    la a0, test_input_2 
    li a1, 92 
    li a2, 0
    jal test_add_overflow # add to overflow

    mv a3, a0
    addi a0, s1, 384 # hash 32
    la a1, test_input_5
    li a2, 43
    jal test_add # add to test case array

    # case 1 -- should be found not from overflow
    li a0, 5
    la a1, test_input_1
    li a2, 154
    jal test_runner

    # case 2 -- should be found from overflow
    li a0, 5
    la a1, test_input_2
    li a2, 92
    jal test_runner

    # case 3 -- should not be found
    li a0, 5
    la a1, test_input_3
    li a2, -1
    jal test_runner

    # --- PART 3: DELETE_COL TEST ---

    # print header
    la a0, test_default_running
    ecall
    la a0, test_part3_delete_running
    ecall

    # insert sample data
    addi a0, s0, 276 # hash 23
    la a1, test_input_4 # not in overflow
    li a2, 83
    li a3, 0
    jal test_add # add to test case array

    la a0, test_input_2
    li a1, 92 
    li a2, 0
    jal test_add_overflow # add to overflow

    mv a3, a0
    addi a0, s0, 384 # hash 32
    la a1, test_input_5
    li a2, 43
    jal test_add # add to test case array

    # case 1 -- should be deleted not from overflow
    li a0, 7
    la a1, test_input_1
    li a2, 0
    jal test_runner

    # case 2 -- should be deleted from overflow
    sw zero, 392(s0)
    li a0, 7
    la a1, test_input_2
    li a2, 0
    jal test_runner

    # case 3 -- should not be found
    li a0, 7
    la a1, test_input_3
    li a2, -1
    jal test_runner

    # end program
    li a7, 10
    ecall

#------------------------------------------------------------------------------
# alloc
# This function fake allocates 3 words of memory in a buffer. The amount 
# available depends on the size of alloc_buffer.
# 
# Returns:
#   a0: pointer to 3-word area safe for use
# 
# Register Usage:
#   t0: memory address of alloc_pointer, so we can increment it
#   t1: new address of the end of alloc_buffer used
#-----------------------------------------------------------------------------
alloc:

    la t0, alloc_pointer # load addr of alloc_pointer
    lw a0, 0(t0) # load addr of the end of the used portion of alloc_buffer
    addi t1, a0, 12 # move pointer by 12 (3 words)
    sw t1, 0(t0) # save new end of alloc_buffer into alloc_pointer

    ret

#------------------------------------------------------------------------------
# test_runner
# This function runs a test and displays an output.
# 
# Args:
#   a0: type of test
#   a1: pointer to key (string) or string 1
#   a2: value or expected return value
#   a3: pointer to string 2 (for equals test)
# 
# Register Usage:

#-----------------------------------------------------------------------------
test_runner:

    # save registers
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    # save args into registers
    mv s0, a2
    mv s1, a0

    # set return register once any test finishes
    # this is done so we can use jumps rather than jump and links
    la ra, test_done

    # determine type of test
    beqz s1, test_hash
    li t0, 1
    beq t0, s1, test_equals
    la a0, test_array # load address to test array, since the next tests need it
    li t0, 2
    beq t0, s1, test_insert
    li t0, 3
    beq t0, s1, test_insert_col
    li t0, 4
    beq t0, s1, test_find
    li t0, 5
    beq t0, s1, test_find_col
    li t0, 6
    beq t0, s1, test_delete
    li t0, 7
    beq t0, s1, test_delete_col

    # run student solution
    test_equals:
        mv a0, a3 
        j equals
    test_hash:
        mv a0, a1
        j hash
    test_insert:
        j insert
    test_insert_col:
        j insert_col
    test_find:
        j find
    test_find_col:
        j find_col
    test_delete:
        j delete
    test_delete_col:
        j delete_col

    test_done:

    # check return values

    # check if either the value and/or array needs to be checked
    li t0, 2
    blt s1, t0, test_check_val
    li t0, 4
    blt s1, t0, test_check_arr

    # compare the return value to the expected value
    test_check_val:
        li a7, 4
        bne a0, s0, test_fail_ret

    # compare the final array to the expected array
    test_check_arr:
    li t0, 2
    beq s1, t0, test_compare_array
    li t0, 6
    beq s1, t0, test_compare_array
    li t0, 3
    beq s1, t0, test_compare_overflows
    li t0, 7
    beq s1, t0, test_compare_overflows
    
    # display message depending on result
    test_pass_ret:
        la a0, test_pass
        j test_ret
    test_fail_ret:
        la a0, test_fail
    test_ret:

    ecall # print message to screen

    # restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12

    ret

#------------------------------------------------------------------------------
# test_compare_overflows
# This sub-routine checks if the two test arrays (test_case_array and 
# test_array) arrays with overflow are identical. Note that this function only 
# compares strings via their pointer values and not their true values for 
# simplicity.
# 
# Register Usage:
#   t0: temporary value for array 1
#   t1: temporary value for array 2
#   t2: current location in main array 1
#   t3: current location in main array 2
#   t4: number of remaining hash table values
#   t5: current element in array 1, incl. overflows
#   t6: current element in array 2, incl. overflows
#-----------------------------------------------------------------------------
test_compare_overflows:
    
    # setup values
    la t2, test_case_array
    la t3, test_array
    li t4, 64
    
    test_compare_overflows_loop:
    # get values for the current item 
    mv t5, t2
    mv t6, t3

    test_compare_overflows_pointer_loop:
    
    # check if we are at the end of the array, end if we are
    beqz t4, test_pass_ret
    
    # compare keys
    lw t0, 0(t5)
    lw t1, 0(t6)
    bne t0, t1, test_fail_ret

    # compare values
    lw t0, 4(t5)
    lw t1, 4(t6)
    bne t0, t1, test_fail_ret

    # check if there is an overflow
    lw t0, 8(t5)
    lw t1, 8(t6)

    # check if pointers mismatch (ex. one has a pointer, the other does not)
    bnez t0, test_compare_overflows_pointer_check
    bnez t1, test_fail_ret

    # there is no pointer, so finish
    j test_compare_overflows_done

    test_compare_overflows_pointer_check:
    beqz t1, test_fail_ret
    
    test_compare_overflows_pointer_check_done:

    # there exists some pointer, so set that as the current one
    mv t5, t0
    mv t6, t1

    # loop to the next pointer
    j test_compare_overflows_pointer_loop

    test_compare_overflows_done:

    # increment for next iteration
    addi t2, t2, 12
    addi t3, t3, 12
    addi t4, t4, -1

    # jump to next iteration
    j test_compare_overflows_loop


#------------------------------------------------------------------------------
# test_compare_array
# This sub-routine checks if the two test arrays (test_case_array and 
# test_array) arrays without overflow are identical. Note that this function 
# only compares strings via their pointer values and not their true values for 
# simplicity.
# 
# Register Usage:
#   t0: temporary value for array 1
#   t1: temporary value for array 2
#   t2: current location in main array 1
#   t3: current location in main array 2
#   t4: number of remaining hash table values
#-----------------------------------------------------------------------------
test_compare_array:

    # setup values
    la t2, test_case_array
    la t3, test_array
    li t4, 128
    
    test_compare_array_loop:

    # check if we have exauseted every item
    beqz t4, test_pass_ret

    # compare two array elements
    lw t0, 0(t2)
    lw t1, 0(t3)
    bne t0, t1, test_fail_ret

    # increment for next iteration
    addi t2, t2, 4
    addi t3, t3, 4
    addi t4, t4, -1

    # jump to next iteration
    j test_compare_array_loop

#------------------------------------------------------------------------------
# test_print_array
# This function displays a representation of a hash table, with no overflow and 
# length 128 words.
# 
# Args:
#   a0: address of array
# 
# Register Usage:
#   t0: address of array element
#   t1: length of hash table (words / 2)
#   t2: current index during loop
#   a0: ecall print input
#   a7: ecall print code
#-----------------------------------------------------------------------------
test_print_array:

    # setup values
    mv t0, a0
    li t1, 64
    li t2, 0

    test_print_array_loop:

        # check if the loop has reached the end
        beq t2, t1, test_print_array_end

        # print index
        mv a0, t2
        li a7, 1
        ecall

        # print seperator
        la a0, test_seperator
        li a7, 4
        ecall

        # check if the string (key) is empty
        lw a0, 0(t0)
        bnez a0, test_print_array_entry

        # check if the value exists 
        lw a0, 4(t0)
        bnez a0, test_print_array_null

        # print empty if the key is empty
        la a0, test_empty
        ecall

    test_print_array_iter:

        # increment for next iteration
        addi t0, t0, 8
        addi t2, t2, 1

        # jump to next iteration
        j test_print_array_loop

    test_print_array_null:
    	
    	# print null representation
    	la a0, test_null

    test_print_array_entry:

        # branch here if there is an entry

        # print key
        ecall

        # print colon (to seperate key/value)
        la a0, test_colon
        ecall

        # print value
        lw a0, 4(t0)
        li a7, 1
        ecall

        # print new line value
        la a0, test_new_line
        li a7, 4
        ecall
        
        # get ready for next iteration
        j test_print_array_iter

    test_print_array_end:

    ret

#------------------------------------------------------------------------------
# test_print_array_col
# This function displays a representation of a hash table, with overflow and 
# length 196 words.
# 
# Args:
#   a0: address of array
# 
# Register Usage:
#   t0: address of current element to display
#   t1: length of hash table (words / 3)
#   t2: current location 
#   t4: address of current array element
#   t5: index of current array item
#   a0: ecall print input
#   a7: ecall print code
#-----------------------------------------------------------------------------
test_print_array_col:
    
    # setup values
    mv t0, a0
    li t1, 64
    li t2, 0
    mv t4, a0
    li t5, 0

    test_print_array_col_loop:

        # check if the loop has reached the end
        bge t5, t1, test_print_array_col_end
        mv t0, t4 # move to a better spot

        # print index
        mv a0, t5
        li a7, 1
        ecall

        # print seperator
        la a0, test_seperator
        li a7, 4
        ecall

        # check if the string (key) is empty
        lw a0, 0(t0)
        bnez a0, test_print_array_col_entry # if not empty, display
        
        # check if the value exists 
        lw a0, 4(t0)
        bnez a0, test_print_array_col_null

        # print empty if the key is empty
        la a0, test_empty
        ecall
        
    test_print_array_col_iter:

        # increment for next iteration
        addi t2, t2, 3
        addi t4, t4, 12
        addi t5, t5, 1

        # jump to next iteration
        j test_print_array_col_loop

    test_print_array_col_null:
    	
    	# print null representation
    	la a0, test_null

    test_print_array_col_entry:

        # branch here if the entry is not empty

        # print key
        ecall

        # print seperator
        la a0, test_colon
        ecall

        # print value
        lw a0, 4(t0)
        li a7, 1
        ecall

        # print arrow
        la a0, test_arrow
        li a7, 4
        ecall

        # check if there is an overflow value
        lw t0, 8(t0)
        beqz t0, test_print_array_col_entry_end
        
        # loop to next value if there is one
        lw a0, 0(t0)
        j test_print_array_col_entry

    
    test_print_array_col_entry_end:

        # print new line
        la a0, test_new_line
        li a7, 4
        ecall

        # setup for next iteration
        j test_print_array_col_iter

    test_print_array_col_end:

    ret

#------------------------------------------------------------------------------
# test_clear_array
# This function clears an array by setting every value to 0.
# 
# Args:
#   a0: address of array
# . a1: length of array (in words)
# 
# Register Usage:
#   --- NONE ---
#-----------------------------------------------------------------------------
test_clear_array:

    sw zero, 0(a0) # save zero to the specified spot
    addi a0, a0, 4 # increment address
    addi a1, a1, -1 # decrement length
    bnez a1, test_clear_array # repeat if the length is not zero

    ret

#------------------------------------------------------------------------------
# test_clear_arrays
# This function clears test_array and test_case_array, both of length 196 words.
# 
# Args:
#   --- NONE ---
#
# Register Usage:
#   --- NONE ---
#-----------------------------------------------------------------------------
test_clear_arrays:

    # save registers
    addi sp, sp, -4
    sw ra, 0(sp)

    # clear test_array using test_clear_array
    la a0, test_array
    li a1, 192
    jal test_clear_array

    # clear test_case_array using test_clear_array
    la a0, test_case_array
    li a1, 192
    jal test_clear_array

    # restore registers
    lw ra, 0(sp)
    addi sp, sp, 4

    ret



#------------------------------------------------------------------------------
# test_add
# This function adds a sample value into a hash table. This is used to generate 
# test cases. The length of the inserted data will either be 2 words or 3 words,
# depending on whether a3 is 0 or not.
# 
# Args:
#   a0: address of where to insert (addr. of where the key will be inserted)
# . a1: pointer of key
#   a2: value
#   a3: pointer to overflow block; if 0, it will not be rewritten.
# 
# Register Usage:
#   --- NONE ---
#-----------------------------------------------------------------------------
test_add:

    # save key and value
    sw a1, (a0)
    sw a2, 4(a0)

    # save overflow pointer, if its value is not zero
    beqz a3, test_add_done
    sw a3, 8(a0)

    test_add_done:
    ret

#------------------------------------------------------------------------------
# test_add_overflow
# This function allocates a new block and inserts sample value, used to generate
# test cases. The length is always 3 words, dictated by the alloc function.
# 
# Args:
# . a0: pointer to key
#   a1: value
#   a2: pointer to next overflow block
# 
# Register Usage:
# . s0: saved pointer to key
#   s1: saved value
#   s2: saved pointer to next overflow block
#-----------------------------------------------------------------------------
test_add_overflow:

    # save registers
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    # save arguments
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # allocate memory
    jal alloc

    # save values into new memory block
    sw s0, 0(a0)
    sw s1, 4(a0)
    sw s2, 8(a0)

    # restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16

    ret
