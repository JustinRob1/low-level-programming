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
#---------------------------------------------------------------
# CCID: jtrober1                 
# Lecture Section: A1
# Instructor: Matthew Gaudet     
# Lab Section: D09        
# Teaching Assistants: Islam Ali, Mostafa Yadegari   
#---------------------------------------------------------------
# 

.include "common.s"
#------------------------------------------------------------------------------
# checksum
# Calculates the checksum of the packet's header 
# 
# Args:
#   a0: starting address of an IP packet in memory
#
# Returns:
#   a0: calculated checksum of the packet in the lower halfword in big-endian byte order
# 
# Register Usage:
#   s0: Stores the starting address of an IP packet in memory
#   s1: Stores the array index i
#   s2: Stores the accumulator
#   s3: Stores the value 5
#   s4: Stores the packet header length 
#   t0: Used to store the sum of the accumulator and halfword each iteration and stores immediates
#   t1: Used to store the sum of the accumulator + halfword
#   t2: Used to store the carryout of the accumulator + halfword
#-----------------------------------------------------------------------------
checksum:
    addi    sp, sp, -24  # Make room for 6 registers
    sw      ra, 20(sp)   # Save ra onto the stack
    sw      s4, 16(sp)   # Save s4 onto the stack
    sw      s3, 12(sp)   # Save s3 onto the stack
    sw      s2, 8(sp)    # Save s2 onto the stack
    sw      s1, 4(sp)    # Save s1 onto the stack
    sw      s0, 0(sp)    # Save s0 onto the stack
    mv      s0, a0       # Save the address of the IP packet into s0 since a0 will get overwritten
    jal     getHeaderLength # Get the value of the packet's Packet Header Length field
    # Multiple by 2 since the Packet Header Length field contains the length of
    # the header in words but we need to iterate over (length * 2) halfwords
    li      t0, 2        # t0 <- 2
    mul     a0, a0, t0   # length <- length * 2
    mv      s4, a0       # Save the length into s4 since a0 will be overwritten
    li      s1, 0        # i <- 0
    li      s2, 0        # accumulator <- 0
    li      s3, 5        # s3 <- 5
    # Break the packet header into halfwords and for each halfword in the header add it to the accumulator
    # Then add the carryout plus the sum to the accumulator
    checkLoop:
        lhu     a0, 0(s0)  # t0 <- Hi
        jal     flipHalfwordBytes # Must flip the bytes in the lower halfword
        add     t0, s2, a0  # t0 <- accumulator + Hi
        li      t1, 0xffff  # t1 <- 0xffff (Want to get lower half word which represents the sum)
        and     t1, t1, t0  # t1 <- sum
        li      t2, 0xf0000 # t2 <- 0xf0000 (Want to get the 5th byte which represents the carryout (either 1 or 0))
        and     t2, t2, t0  # t2 <- carryout
        srli    t2, t2, 16  # Shift the carryout into the 0th bit position
        add     s2, t1, t2  # accumulator <- sum + carryout
        addi    s0, s0, 2   # s0 <- s0 + 2 (Want to get the next halfword of the packet header)
        addi    s1, s1, 1   # i <- i + 1
        # When i = 5 then the current halfword will be the header checksum so we must skip this halfword
        beq     s1, s3, skip # If i = 5 branch to skip label
        blt     s1, s4, checkLoop # If i < packet header length continue loop
    li     t0, 0xffff      # t0 <- 0xffff
    xor    a0, s2, t0      # Return the logical complement of the accumulator

    # Restore registers and return to caller
    exit:
        lw      ra, 20(sp)   # Restore ra from the stack
        lw      s4, 16(sp)   # Restore s4 from the stack
        lw      s3, 12(sp)   # Restore s3 from the stack 
        lw      s2, 8(sp)    # Restore s2 from the stack
        lw      s1, 4(sp)    # Restore s1 from the stack
        lw      s0, 0(sp)    # Restore s0 from the stack
        addi    sp, sp, 24   # Restore stack pointer
        ret  # Return to caller
    
    # Increment i by 1 and jump to checkLoop to skip the header checksum halfword
    skip:
        addi    s0, s0, 2   # s0 <- s0 + 2 (Skip the header checksum halfword)
        addi    s1, s1, 1   # i <- i + 1
        j       checkLoop   # Jump back to the checkLoop

#------------------------------------------------------------------------------
# flipHalfwordBytes
# Given a word, swaps the bytes in the lower halfword
# 
# Args:
#   a0: two bytes stored in the lower halfword
#
# Returns:
#   a0: the reverse order of the input bytes in the lower halfword
# 
# Register Usage:
#   t0: Stores the lower byte of the lower halfword
#   t1: Stores the upper byte of the lower halfword
#-----------------------------------------------------------------------------
flipHalfwordBytes: 
    li      t0, 0xff00 # t0 <- 0xff00
    and     t1, a0, t0 # Set t1 the upper byte of the lower halfword
    li      t0, 0x00ff # t0 <- 0x00ff
    and     t0, a0, t0 # Set t0 to the lower byte of the lower halfwrod
    slli    t0, t0, 8  # Shift the lower byte into the upper byte position
    srli    t1, t1, 8  # Shift the upper byte into the lower byte position
    add     a0, t0, t1 # t0 <- t0 + t1 (Return the reverse order of the input bytes in the lower halfword)
    ret                # Return to the caller

#------------------------------------------------------------------------------
# getHeaderLength:
# Given a packet, finds and loads the value stored in its packet header length field
# 
# Args:
#   a0: starting address of an IP packet in memory
#
# Returns:
#   a0: the value of the packet's Packet Header Length field in the lowest four bits
# 
# Register Usage:
#   No additional registers required
#-----------------------------------------------------------------------------
getHeaderLength:
    lbu     a0, 0(a0)   # Load the packet header length into a0
    andi    a0, a0, 0xf # We just need the lowest four bits so andi with 0xf to get the packet header length
    ret                 # Return to the caller

