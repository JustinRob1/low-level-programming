.text
#-------------------------------------------------------------------------------
# flipBitInByte
# Replaces the specified character in memory with a character where the specified bit is flipped.
#
# Arguments:
#       a0: address of character in memory.
#	    a1: an integer between zero and seven that specifies a bit to be flipped.
# Return Values:
#       None
# Side Effects:
#       None
# Register Usage:
#       t0: Stores the character at the address specified in memory.
#       t1: Stores a 1 at the position of the bit to be flipped and the new character
#       that is the result of flipping the bit. 
#-------------------------------------------------------------------------------
flipBitInByte:
    lbu       t0, 0(a0)      # t0 <- The character at the specified memory
    addi      t1, t1, 1      # t1 <- t1 + 1
    sll       t1, t1, a1     # Shifts the 1 into the position specified by a1, store result in t1
    xor       t1, t0, t1     # Flips the bit at the position specified by a1, store result in t1
    sb        t1, 0(a0)      # Store the new character back at the specified memory location
    jalr      zero, ra, 0    # Return to the caller