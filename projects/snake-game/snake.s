#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2020 University of Alberta
# Copyright 2022 Yufei Chen
# Copyright 2022 <Justin Robertson>
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
# Lab_Snake_Game Lab
#
# Author: Justin Robertson
# Date: November 15, 2022
# TA: Islam Ali, Mostafa Yadegari
#
#-------------------------------

.include "common.s"

.data
.align 2

DISPLAY_CONTROL:    .word 0xFFFF0008
DISPLAY_DATA:       .word 0xFFFF000C
INTERRUPT_ERROR:	.asciz "Error: Unhandled interrupt with exception code: "
INSTRUCTION_ERROR:	.asciz "\n   Originating from the instruction at address: "
	
iFlag:       .word   0   # Flag for the intro screen loop
endGame:     .word   0   # Flag for the game loop to determine if time is up or snake hit a wall
gFlag:       .word   0   # Flag for game loop that is changed to 1 every second to indicate the game screen 
                         # Needs to be updated
direction:   .asciz  "d" # The direction the snake is travelling

initialTime: .asciz  "120" # The initial time and also the current time of the game
bonusTime:   .word   8     # How much bonus time is awarded for eating an apple
userPoints:  .asciz  "000" # The points the user has

appleCol:    .word   0  # The col the current apple is at
appleRow:    .word   0  # The row the current apple is at
positions:   .space  10 # An array of 10 bytes to store the snake head and snake body
# Every even byte and 0 are the rows of the snake head of body and every odd byte is the col
# of the snake head or body. The 8th and 9th bytes hold the previous position of the 'tail' of the snake
# so a white character can be printed at its location after the snake moves

Brick:       .asciz "#" 
whiteSpace:  .asciz " "
snakeHead:   .asciz "@"
snakeBody:   .asciz "*"
apple:       .asciz "a"

introMsg: .asciz "Please enter 1, 2 or 3 to choose the level and start the game"
points:      .asciz "points"
seconds:     .asciz "seconds"

.text


#---------------------------------------------------------------------------------------------
# snakeGame
# Runs a simple snake game that a user can play with three different levels.
# 
# Args:
#   None
#
# Register Usage
#   a0: Used as an input to printStr
#   a1: Used as an input to printStr
#   a2: Used as an input to printStr
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
snakeGame:
	addi sp, sp, -4  # Make room for 1 item on the stack
	sw   ra, 0(sp)   # Save ra onto the stack
	csrwi 0, 0x1    # Enable user-level interrupts by setting bit 0 to 1 in ustatus register
	csrwi 4, 0x110  # Enables user interrupts for timer and keyboard by setting bit 4 and 8 to 1 in uie register
	li    t0, 0xffff0020 # t0 <- Addr[timecmp]
   li    t1, 1000  # t1 <- 1000
   sw    t1, 0(t0) # Set timecmp to 1000 ms
	li 	t0, 0x2   # t0 <- 0x2
	li    t1, 0xffff0000 # t1 <- Addr[keyboard control]
	sw    t0, 0(t1) # Enable keyboard interrupts by setting bit 1 to 1 in keyboard control register
	la    t0, introMsg   # t0 <- introMsg
   mv    a0, t0         # a0 <- introMsg
   li    a1, 0          # a1 <- row = 0
   li    a2, 0          # a2 <- col = 0
   # Print introMsg starting at row 0 col 0
   jal   printStr       # Uses printStr from displayDemo.s
   la    t0, handler    # Load the address of handler into t0
   csrrw t0, 5, t0      # Load the address of handler into utvec
   # Continue looping until the user enters 1, 2 or 3 to select game difficulty
   introLoop:
   	la    t1, iFlag  # t1 <- Addr[iFlag]
    	lw    t1, 0(t1)  # t1 <- iFlag
    	beq   t1, zero, introLoop # If iFlag is still 0 the user hasen't entered a valid input, continue looping
    	                          # else the user entered a valid input, exit the loop

   jal  initialize      # Jump to initialize function to set and print all the starting values
   # Continue looping until endGame flag is not 0
   gameLoop:
    	la   t0, gFlag   # t0 <- Addr[gFlag]
    	lw   t0, 0(t0)   # t0 <- gFlag
    	bne  t0, zero, update # If gFlag is not 0 then 1 second has passed, we must update the game screen
    	la   t0, endGame # t0 <- Addr[endGame]
    	lw   t0, 0(t0)   # t0 <- endGame
    	beq  t0, zero, gameLoop # If endGame flag is 
   lw   ra, 0(sp)   # Restore ra from stack
	addi sp, sp, 4   # Restore stack pointer
   jalr  zero, ra, 0   # Return to common.s

#--------------------------------s-------------------------------------------------------------
# random
# Using the LCG algorithm, calculate Xi from Xi-1, a, c, and m. Replaces Xi-1 in memory with the newly generated Xi.
# 
# Args:
#   None
#
# Register Usage
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	a0: a pseudorandom number, Xi, between 0 and 8
#---------------------------------------------------------------------------------------------
random:
	la   t0, aVar    # t0 <- Addr[aVar]
	lw   a0, 0(t0)   # a0 <- aVar
	la   t0, XiVar   # t0 <- Addr[XiVar]
	lw   t0, 0(t0)   # t0 <- XiVar
	mul  a0, a0, t0  # a0 <- aVar * XiVar
	la   t0, cVar    # t0 <- Addr[cVar]
	lw   t0, 0(t0)   # t0 <- cVar
	add  a0, a0, t0  # a0 <- (aVar * XiVar) + cVar
	la   t0, mVar    # t0 <- Addr[mVar]
	lw   t0, 0(t0)   # t0 <- mVar
	rem  a0, a0, t0  # a0 <- ((aVar * XiVar) + cVar) % mVar
	la   t0, XiVar   # t0 <- Addr[XiVar]
	sw   a0, 0(t0)   # Addr[XiVar] <- ((aVar * XiVar) + cVar) % mVar
	jalr zero, ra, 0 # Return to caller
	
#---------------------------------------------------------------------------------------------
# update
# 1 second has passed in the program, the game screen must be uredrawn and values must be updated
# 
# Args:
#   None
#
# Register Usage
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
update: 
	addi sp, sp, -4      # Make room for 1 item on the stack
	sw   ra, 0(sp)      # Save ra onto the stack
	jal  moveSnake      # Update the position of the snake head and body to move 1 unit
	jal  checkApple     # Check if the snake ate an apple and draw a new apple if so
	jal  drawSnake      # Draw the snake head and body
	jal  checkHit       # Check if the snake hit a wall

	la   t0, initialTime # t0 <- Addr[initialTime]
	lbu  t1, 2(t0)       # t1 <- right digit of initialTime
	li   t2, 0x30        # t2 <- 0x30 (ascii 0)
	beq  t1, t2, zeroThird # If right digit is 0 the branch to zeroThird label
	addi t1, t1, -1      # Else decrease the right by 1
	sb   t1, 2(t0)       # Store decremented the right digit back into memory
	j    continueUpdate  # Jump to continueUpdate

	# Branch here if the right digit is 0, check to see if the middle digit is also zero
	zeroThird:
		lbu  t1, 1(t0)  # t1 <- middle digit of initialTime
		beq  t1, t2, zeroSecond # If the middle digit is also zero then branch to zeroSecond label
		# Else the middle digit is not zero so we can subtract 1 from it
		addi t1, t1, -1 # Subtract 1 from the middle digit
		sb   t1, 1(t0)  # Store the decremented middle digit back into memory
		li   t1, 0x39   # t1 <- 0x39 (ascii 9)
		sb   t1, 2(t0)  # Store 9 as the right digit back into memory
		j    continueUpdate # Jump to continueUpdate

	# Branch here if both the middle digit and the right digit are both 0
	zeroSecond:
		li   t1, 0x39   # t1 <- 0x39 (ascii 9)
		sb   t1, 2(t0)  # Store 9 as right digit back into memory
		sb   t1, 1(t0)  # Store 9 as middle digit back into memory
		lbu  t1, 0(t0)  # t1 <- left digit
		addi t1, t1, -1 # Subtract 1 from left digit
		sb   t1, 0(t0)  # Store the decremented left digit back into memory
		j    continueUpdate # Jump to continueUpdate

	# Jump to list label after the timer has been updated
	continueUpdate:
		jal  printTimeScore # Jump to printTimeScore to print the updated time and score
		jal  checkTime      # Jump to checkTime to see if the timer has hit 000
		la   t0, gFlag      # t0 <- Addr[gFlag]
		li   t1, 0          # t1 <- 0
		# Set the gFlag back to 0 to indicate that the updated game screen has been printed
		sw   t1, 0(t0)      # Addr[gFlag] <- 0
		lw   ra, 0(sp)      # Restore ra
		addi sp, sp, 4      # Restore stack pointer
		jalr zero, ra, 0    # Return to caller

#---------------------------------------------------------------------------------------------
# initialize
# Draws the first screen of the game and sets the initialize values for the apple location and snake location
# 
# Args:
#   None
#
# Register Usage
#   a0: Used as an input to print fucntions
#   a1: Used as an input to print functions
#   a2: Used as an input to print functions
#   a3: Used as an input to print functions
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#   t3: Acts as a temporary variable that stores addresses, immediates and words
#   s0: Stores the address of the positions array in memory
#   s1: Acts as the variable i in the loop
#   s2: Stores the value 3 to act as a range limit for the loop
#   
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
initialize:
	addi   sp, sp, -16 # Make room for four items on the stack
	sw     ra, 0(sp)   # Save ra onto stack
	sw     s0, 4(sp)   # Save s0 onto stack
	sw     s1, 8(sp)   # Save s1 onto stack
	sw     s2, 12(sp)  # Save s2 onto stack

   li   a0, 61   # a0 <- 61
   li   a1, 0    # a1 <- 0
   li   a2, 0    # a2 <- 0
   li   a3, 0x20 # a3 <- 0x20 (space character ascii)
   # Print 60 space characters staring at row 0 col 0 to get rid of the intro message
   jal  printMultipleSameChars # Uses printMultipleSameChars from displayDemo.s
   jal  printAllWalls          # Uses printAllWalls from displayDemo.s
 
   la  t0, positions # t0 <- Addr[positions]
   li  t1, 5 # t1 <- 5 (The snake starts at row 5)
   li  t2, 0 # t2 <- i = 0
   li  t3, 4 # t3 <- 4

   # The first byte of the positions array is the row of the snake head and the next byte is the col
   # of the snake head. The next 6 bytes is the row and col of each part of the snake body
   # Set the starting row for each part of the snake
   initializeRow:
      sb   t1, 0(t0) # Store the row into the positions array
    	addi t0, t0, 2 # Increment address to the row of the next snake part
    	addi t2, t2, 1 # i <- i + 1
    	blt  t2, t3, initializeRow # While i < 4 continue loop

   la   t0, positions # t0 <- Addr[positions]
   addi t0, t0, 1 # Increment address to the col of the snake head
   li   t1, 10 # t1 <- 10 (The snake head starts at col 10)
   li   t2, 0  # t2 <- 0
   # Set the starting column for each part of the snake
   initializeCol:
    	sb   t1, 0(t0)  # Store the col into the positions array
    	addi t1, t1, -1 # Decrement the col by 1 each iteration since the snake body is behind the snake head
    	addi t0, t0, 2  # Increment address to the row of the next snake part
    	addi t2, t2, 1  # i <- i + 1
    	blt  t2, t3, initializeCol # While i < 4 continue loop

   la    t0, snakeHead # t0 <- Addr[snakeHead]
   lbu   a0, 0(t0)     # a0 <- '@'
   la    t0, positions # t0 <- Addr[positions]
   lbu   a1, 0(t0)     # a1 <- row of snake head
   lbu   a2, 1(t0)     # a2 <- col of snake head
   # Call printChar to print the snakeHead
   jal   printChar     # Uses printChar from displayDemo.s

   la   t0, snakeBody # t0 <- Addr[snakeBody]
   lbu  a0, 0(t0)     # a0 <- '*'
   la   s0, positions # s0 <- Addr[positions]
   addi s0, s0, 2     # Move address to the row of the first snake body part
   li   s1, 0         # i <- 0
   li   s2, 3         # s2 <- 3
   # Loop through positions array to print each body part of the snake
   printBodyI:
    	lbu  a1, 0(s0) # a1 <- row of body part
    	lbu  a2, 1(s0) # a2 <- col of body part 
    	jal  printChar # Uses printChar from displayDemo.s
    	addi s0, s0, 2 # Increment address to the row of the next snake part
    	addi s1, s1, 1 # i <- i + 1
    	blt  s1, s2, printBodyI # While i < 3 continue loop
   jal drawNewApple   # Jump to drawNewApple to print the starting apple
   jal printTimeScore # Jump to printTimeScore to print the starting time and score
 
   la  a0, points   # a0 <- Addr[points]
   li  a1, 0        # a1 <- 0
   li  a2, 28       # a2 <- 28
   # Print the string 'points' starting at the row 0 and the column 28
   jal printStr     # Uses printStr from displayDemo.s
   la  a0, seconds  # a0 <- Addr[seconds]
   li  a1, 1        # a1 <- 1
   li  a2, 28       # a2 <- 28
   # Print the string 'seconds' starting at the row 1 and the column 28
   jal printStr     # Uses printStr from displayDemo.s

   lw     ra, 0(sp)   # Restore ra
	lw     s0, 4(sp)   # Restore s0
	lw     s1, 8(sp)   # Restore s1
	lw     s2, 12(sp)  # Restore s2
	addi   sp, sp, 16  # Restore stack pointer
	jalr   zero, ra, 0 # Return to caller

#---------------------------------------------------------------------------------------------
# handler
# Handles all interrupts and exceptions.
#---------------------------------------------------------------------------------------------
handler:
 # swap uscratch and a0
   csrrw a0, 0x040, a0 # a0 <- Addr[iTrapData], uscratch <- PROGRAMa0
   # save registers used in the handler except a0
   sw t0, 0(a0)   # Save t0
   sw t1, 4(a0)   # Save t1
   sw t2, 8(a0)   # Save t2
   # store USERa0
   csrr   t0, 0x040  # t0 <- PROGRAMa0
   sw     t0, 12(a0)  # save PROGRAMa0

   li 	 t1, 0           # t1 <- 0
   csrrw  t0, 0x42, t1 	  # Move cause to t0 and clear it
   li     t1, 0x80000000  # t1 <- 0x80000000
   and    t2, t1, t0      # Get the 32th bit 
   beq    t2, zero, exit  # If the 32th bit is zero then we have an exception, branch to exit
   li 	 t1, 0x7FFFFFFF  # t1 <- 0x7FFFFFFF
   and 	 t0, t0, t1   	  # Extract exception code field
   li     t1, 4           # t1 <- 4
   beq    t0, t1, timerInterrupt  # If exception code is 4 then we have a timer error, branch to timerInterrupt label
   li 	 t1, 8           # t1 <- 8
   beq    t0, t1, keyboardError # If exception code is 8 then we have a keyboard error, branch to keyboardError label
   j	    exit   	# Else the interrupt is not a keyboard interrupt or timer interrupt, jump to the exit

   # The interrupt is a timer interrupt, set the gFlag to 1 and increase timecmp by 1000 ms
   timerInterrupt:
      la   t0, gFlag  # t0 <- Addr[gFlag]
      li   t1, 1      # t1 <- 1
      sw   t1, 0(t0)  # gFlag <- 1 
      li   t0, 0xffff0020 # t0 <- Addr[timecmp]
      lw   t1, 0(t0)  # t1 <- timecmp
      addi t1, t1, 1000 # timecmp <- timecmp + 1000
      sw   t1, 0(t0)  # Addr[timecmp] <- timecmp
      j    timerExit   # Jump to timerExit

   # The interrupt is a keyboard interrupt, determine if we are at the intro screen or game screen
   keyboardError:
      la  t0, iFlag # t0 <- Addr[iFlag]
   	lw  t0, 0(t0) # t0 <- iFlag
      bne t0, zero, keyboardGame # If iFlag is not 0 that means we are in the game loop, branch to keyboardGame label
      # Else determine if 1, 2 or 3 was pressed
      li   t0, 0xffff0004   # t0 <- Addr[keyboard data]
	   lw   t0, 0(t0)        # t0 <- ASCII value of last key pressed
	   li   t1, 0x31         # t0 <- 0x31 (ASCII 1)
	   beq  t0, t1, setFlag  # IntialTime and bonus time are by default 120 and 8 so just branch to setFlag label if the key was 1
	   li   t1, 0x32         # t0 <- 0x32 (ASCII 2)
	   beq  t0, t1, setDiff2 # If the last key pressed was 2 branch to setDiff2
	   li   t1, 0x33         # t0 <- 0x33 (ASCII 3)
	   beq  t0, t1, setDiff3 # If the last key pressed was 3 branch to setDiff3
	   # Some other key was pressed, just jump to keyExit
	   j    keyExit  

	# The last key pressed was 2, set initialTime to 30 and bonus time to 5
   setDiff2:
	   la   t2, initialTime # t2 <- Addr[initialTime]
	   li   t1, 0x30        # t1 <- 0x30 (ASCII 0)
	   sb   t1, 0(t2)       # Store 0 into the left digit position
	   li   t1, 0x33        # t1 <- 0x33 (ASCII 3)
	   sb   t1, 1(t2) 		# Store 3 into the middle digit position
	   li   t1, 5           # t1 <- 5
	   la   t2, bonusTime   # t2 <- Addr[bonusTime]
	   sw   t1, 0(t2)       # Set bonus time to 5
	   j    setFlag 

	# The last key pressed was 3, set initialTime to 15 and bonus time to 3
   setDiff3:
	   la   t2, initialTime # t2 <- Addr[initialTime]
	   li   t1, 0x30  	   # t1 <- 0x30 (ASCII 0)
	   sb   t1, 0(t2)  	   # Store 0 into the left digit position
	   li   t1, 0x31  		# t1 <- 0x31 (ASCII 1)
	   sb   t1, 1(t2) 		# Store 1 into the middle digit position
	   li   t1, 0x35  		# t1 <- 0x35 (ASCII 5)
	   sb   t1, 2(t2) 		# Store 5 into the right digit position
	   li   t1, 3           # t1 <- 3
	   la   t2, bonusTime   # t2 <- Addr[bonusTime]
	   sw   t1, 0(t2)       # Set bonusTime to 3
	   j    setFlag         # Jump to setFlag label

	# Set iFlag to 1 and jump to keyExit
   setFlag:
      li  t0, 1     # t0 <- 1
      la  t1, iFlag # t1 <- Addr[iFlag]
   	sw  t0, 0(t1) # Set iFlag to 1
   	j   keyExit  # Jump to keyExit

   # We are currently in the game loop, determine what the last key pressed was and
   # handle accordingly
   keyboardGame:
   	li   t0, 0xffff0004 # t0 <- Addr[keyboard data]
	   lw   t0, 0(t0)      # t0 <- last key pressed
	   li   t1, 0x77       # t1 <- 0x77 (ASCII w)
	   beq  t0, t1, wKey   # If the last key pressed was w, branch to wKey label
	   li   t1, 0x61       # t1 <- 0x61 (ASCII a)
	   beq  t0, t1, aKey   # If the last key pressed was a, branch to aKey label
	   li   t1, 0x73       # t1 <- 0x73 (ASCII s)
	   beq  t0, t1, sKey   # If the last key pressed was s, branch to sKey label
	   li   t1, 0x64       # t1 <- 0x64 (ASCII d)
	   beq  t0, t1, dKey   # If the last key pressed was d, branch to dKey label
	   # Else some other key was pressed
	   j    keyExit # Jump to keyExit

	# If the pressed key is the opposite direction of the current direction, keep the same direction
	# This is to prevent the snake from turning around

	# The w key was pressed, if direction is w, a, or d then change direction to w
	# else keep the direction s
	wKey:
		la   t0, direction # t0 <- Addr[direction]
		lbu  t0, 0(t0)     # t0 <- direction
		li   t1, 0x73      # t1 <- 0x73 (ASCII s)
		beq  t1, t0, keyExit # If direction is 's' then keep the same direction, branch to keyExit
		# Else change the direction to 'w'
		li   t1, 0x77  # t1 <- 0x77 (ASCII w)
		la   t0, direction # t0 <- Addr[direction]
		sb   t1, 0(t0) # direction <- w
		j    keyExit  # jump to keyExit

   # The a key was pressed, if direction is a, w, or s then change direction to 'a'
	# else keep the direction d
	aKey:
		la   t0, direction # t0 <- Addr[direction]
		lbu  t0, 0(t0) # t0 <- direction
		li   t1, 0x64  # t1 <- 0x64 (ASCII d)
		beq  t1, t0, keyExit # If direction is 'd' then keep the same direction, branch to keyExit
		# Else change the direction to 'a'
		li   t1, 0x61  # t1 <- 0x61 (ASCII a)
		la   t0, direction # t0 <- Addr[direction]
		sb   t1, 0(t0) # direction <- a
		j    keyExit  # jump to keyExit

	# The s key was pressed, if direction is s, a, or d then change direction to s
	# else keep the direction w
	sKey:
		la   t0, direction # t0 <- Addr[direction]
		lbu  t0, 0(t0) # t0 <- direction
		li   t1, 0x77  # t1 <- 0x77 (ASCII w)
		beq  t1, t0, keyExit # If direction is 'w' then keep the same direction, branch to keyExit
		# Else change the direction to 's'
		li   t1, 0x73  # t1 <- 0x73 (ASCII s)
		la   t0, direction # t0 <- Addr[direction]
		sb   t1, 0(t0) # direction <- s
		j    keyExit  # jump to keyExit

	# The d key was pressed, if direction is d, w, or s then change direction to d
	# else keep the direction a
	dKey:
		la   t0, direction # t0 <- Addr[direction]
		lbu  t0, 0(t0) # t0 <- direction
		li   t1, 0x61  # t1 <- 0x61 (ASCII a)
		beq  t1, t0, keyExit # If direction is 'a' then keep the same direction, branch to keyExit
		# Else change the direction to 'd'
		li   t1, 0x64  #  t1 <- 0x64 (ASCII d)
		la   t0, direction # t0 <- Addr[direction]
		sb   t1, 0(t0) # direction <- d
		j    keyExit  # jump to keyExit

  
   # The exception code is not a timer or keyboard interrupt, restore the registers and jump to handler terminate
   exit:
      # load USERa0
      lw   t0, 8(a0) # t0 <- USERa0 
      csrw t0, 0x040  # uscratch <- usera0
      # load registers used in the handler except a0
      lw t0, 0(a0) # Restore t0
      lw s0, 4(a0) # Restore s0
      # swap uscratch and a0
      csrrw a0, 0x040, a0  # a0 <- USERa0, uscratch <- Addr[iTrapData]
      j   handlerTerminate # Jump to handlerTerminate

   # The interrupt has been handled and the values have been set, restore the registers and return to normal 
   # program execution
   keyExit:
   	li 	t0, 0x2
	   li    t1, 0xffff0000
	   sw    t0, 0(t1) # Re-enable keyboard interrupts by setting bit 1 to 1 in keyboard control register
   	# load USERa0
	   lw   t0, 12(a0) # t0 <- USERa0 
	   csrw t0, 0x040  # uscratch <- usera0
	   # load registers used in the handler except a0
	   lw t0, 0(a0) # Restore t0
	   lw t1, 4(a0) # Restore t1
	   lw t2, 8(a0) # Restore t2
	   # swap uscratch and a0
	   csrrw a0, 0x040, a0  # a0 <- USERa0, uscratch <- Addr[iTrapData]
	   uret # Return to EPC 

	timerExit:
		# load USERa0
	   lw   t0, 12(a0) # t0 <- USERa0 
	   csrw t0, 0x040  # uscratch <- usera0
	   # load registers used in the handler except a0
	   lw t0, 0(a0) # Restore t0
	   lw t1, 4(a0) # Restore t1
	   lw t2, 8(a0) # Restore t2
	   # swap uscratch and a0
	   csrrw a0, 0x040, a0  # a0 <- USERa0, uscratch <- Addr[iTrapData]
	   uret # Return to EPC

   
	handlerTerminate:
		# Print error msg before terminating
		li     a7, 4
		la     a0, INTERRUPT_ERROR
		ecall
		li     a7, 34
		csrrci a0, 66, 0
		ecall
		li     a7, 4
		la     a0, INSTRUCTION_ERROR
		ecall
		li     a7, 34
		csrrci a0, 65, 0
		ecall
	handlerQuit:
		li     a7, 10
		ecall	# End of program

#---------------------------------------------------------------------------------------------
# drawSnake
# Draws the snake onto the screen
# 
# Args:
#   None
#
# Register Usage:
#   a0: Used as an input to print fucntions
#   a1: Used as an input to print functions
#   a2: Used as an input to print functions
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   s0: Stores the address of the positions array in memory
#   s1: Acts as the variable i in the loop
#   s2: Stores the value 3 to act as a range limit for the loop
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
drawSnake:
	addi  sp, sp, -16 # Make room on stack for 4 items
	sw    ra, 0(sp)   # Save ra onto stack
	sw    s0, 4(sp)   # Save s0 onto stack
	sw    s1, 8(sp)   # Save s1 onto stack
	sw    s2, 12(sp)  # save s2 onto stack

	la    t0, positions # t0 <- Addr[positions]
	addi  t0, t0, 8 # Move address to the row of the 'white space' position
	lbu   a1, 0(t0) # Load the row of the 'white space' position into a1
	addi  t0, t0, 1 # Move address to the col of the 'white space' position
	lbu   a2, 0(t0) # Load the col of the 'white space' position into a2
	la    a0, whiteSpace # a0 <- Addr[whiteSpace]
	lbu   a0, 0(a0)      # a0 <- ' '
	# Print a white space character to the row and col of the previous position of the snake 'tail'
	# This is to erase the previous position of the tail 
	jal   printChar # Uses printChar from displayDemo.S

   la   t0, snakeBody # t0 <- Addr[snakeBody]
   lbu  a0, 0(t0)     # a0 <- '*'
   la   s0, positions # s0 <- Addr[positions]
   addi s0, s0, 2     # Move address to the row of the first snake body part
   li   s1, 0         # i <- 0
   li   s2, 3         # s2 <- 3
   # Loop through positions array to print each body part of the snake
   printBody:
    	lbu  a1, 0(s0) # a1 <- row of body part
    	lbu  a2, 1(s0) # a2 <- col of body part 
    	jal  printChar # Uses printChar from displayDemo.s
    	addi s0, s0, 2 # Increment address to the row of the next snake part
    	addi s1, s1, 1 # i <- i + 1
    	blt  s1, s2, printBody # While i < 3 continue loop

   la    t0, snakeHead # t0 <- Addr[snakeHead]
   lbu   a0, 0(t0)     # a0 <- '@'
   la    t0, positions # t0 <- Addr[positions]
   lbu   a1, 0(t0)     # a1 <- row of snake head
   lbu   a2, 1(t0)     # a2 <- col of snake head
   # Call printChar to print the snakeHead
   jal   printChar     # Uses printChar from displayDemo.s

   lw     ra, 0(sp)   # Restore ra 
	lw     s0, 4(sp)   # Restore s0
	lw     s1, 8(sp)   # Restore s1
	lw     s2, 12(sp)  # Restore s2
	addi   sp, sp, 16  # Restore stack pointer
	jalr   zero, ra, 0 # Return to caller


#---------------------------------------------------------------------------------------------
# moveSnake
# Moves the position of each part of the snake body to the position of the part in front of it
# 
# Args:
#   None
#
# Register Usage:
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#   t3: Acts as a temporary variable that stores addresses, immediates and words
#   t4: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
moveSnake:
	la   t0, positions # t0 <- Addr[positions]
   addi t0, t0, 9     # Move the address of positions to row of the last byte of the array
  	la   t1, positions # t0 <- Addr[positions]
  	addi t1, t1, 7     # Move the address of positions to row of the second to last byte of the array
  	li   t2, 0  # i <- 0
  	li   t3, 8  # t3 <- 8
  	# Copy the row and col from the next snake part into the current snake part
  	copyLoop:
     	lbu  t4, 0(t1)  # t4 <- row/col of next snake part
     	sb   t4, 0(t0)  # Store the row/col of the next snake part into the position of the snake part behind it
     	addi t1, t1, -1 # Move to the next row/col
     	addi t0, t0, -1 # Move to the next row/col
	  	addi t2, t2, 1  # i <- i + 1
     	blt  t2, t3, copyLoop # While i < 8 continue loop

   # We need to loop 8 times for each snake part (3 * 2 = 6) plus two more times to copy the row and col into
   # the white space position

   la   t0, direction # t0 <- Addr[direction]
   lbu  t0, 0(t0)     # t0 <- direction
	li   t1, 0x77      # t1 <- 0x77 (ASCII w)
	beq  t0, t1, wDir  # If the direction is 'w' then branch to wDir label
	li   t1, 0x61      # t1 <- 0x61 (ASCII a)
	beq  t0, t1, aDir  # If the direction is 'a' then branch to aDir label
	li   t1, 0x73      # t1 <- 0x73 (ASCII s)
	beq  t0, t1, sDir  # If the direction is 's' then branch to sDir label
	li   t1, 0x64      # t1 <- 0x64 (ASCII d)
	beq  t0, t1, dDir  # If the direction is 'd' then branch to dDir label

	# The direction is 'w', decrease the row of the snake head by 1
	wDir:
		la   t0, positions # t0 <- Addr[position]
		lbu  t1, 0(t0)     # t0 <- row of snake head
		addi t1, t1, -1    # row <- row - 1
		sb   t1, 0(t0)     # Store updated row back into memory  
		j    moveSnakeExit # Jump to moveSnakeExit
 
	# The direction is 'a', decrease the col of the snake head by 1
	aDir:
		la   t0, positions # t0 <- Addr[position]
		lbu  t1, 1(t0)     # t0 <- col of snake head
		addi t1, t1, -1    # col <- col - 1
		sb   t1, 1(t0)	    # Store updated col back into memory  
		j    moveSnakeExit # Jump to moveSnakeExit

	# The direction is 's', increase the row of the snake head by 1
	sDir:
		la   t0, positions # t0 <- Addr[position]
		lbu  t1, 0(t0)     # t0 <- row of snake head
		addi t1, t1, 1		 # row <- row + 1
		sb   t1, 0(t0)     # Store updated row back into memory  
		j    moveSnakeExit # Jump to moveSnakeExit

	# The direction is 'd', increase the col of the snake head by 1
	dDir:
		la   t0, positions # t0 <- Addr[position]
		lbu  t1, 1(t0)     # t0 <- col of snake head
		addi t1, t1, 1     # col <- col + 1
		sb   t1, 1(t0)     # Store updated col back into memory  
		j    moveSnakeExit # Jump to moveSnakeExit
   
   # The snake has been moved return to caller
   moveSnakeExit:
	   jalr  zero, ra, 0 # Return to caller

#---------------------------------------------------------------------------------------------
# drawNewApple
# Draws a new apple onto the screen and sets its row and col
# 
# Args:
#   None
#
# Register Usage:
#   a0: Used as an input to print fucntions
#   a1: Used as an input to print functions
#   a2: Used as an input to print functions
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
drawNewApple:
	addi  sp, sp, -4    # Make from for 1 item on the stack
	sw    ra, 0(sp)     # Save ra onto stack
	jal   random        # Jump to random function
   addi  a0, a0, 1     # Add 1 to the pseudorandom number returned
   la    t0, appleRow  # t0 <- Addr[appleRow]
   sw    a0, 0(t0)     # appleRow <- a0
   mv    a1, a0        # a1 <- appleRow
   jal   random        # Jump to random function
   addi  a0, a0, 1     # Add 1 to the pseudorandom number returned
   la    t0, appleCol  # t0 <- Addr[appleCol]
   sw    a0, 0(t0)     # appleCol <- a0
   mv    a2, a0        # a2 <- a0
   la    t0, apple     # t0 <- Addr[apple]
   lbu   a0, 0(t0)     # a0 <- 'a'
   # Print the new apple at the randomly generated location stored in appleRow and appleCol
   jal   printChar     # Uses printChar from displayDemo.S 
   lw    ra, 0(sp)     # Restore ra from stack
   addi  sp, sp, 4     # Restore stack pointer
   jalr  zero, ra, 0   # Return to caller

#---------------------------------------------------------------------------------------------
# printTimeScore
# Prints updated the new time and score onto the screen
# 
# Args:
#   None
#
# Register Usage
#   a0: Used as an input to print fucntions
#   a1: Used as an input to print functions
#   a2: Used as an input to print functions
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printTimeScore:
	addi sp, sp, -4     # Make room for 1 item on the stack
	sw   ra, 0(sp)      # Save ra onto stack
	la   a0, userPoints # a0 <- Addr[userPoints]
   li   a1, 0   # a1 <- 0
   li   a2, 24  # a2 <- 24
   # Print the users points starting at row 0 col 24
   jal  printStr        # Uses printStr from displayDemo.S 
   la   a0, initialTime # a0 <- Addr[initialTime]
   li   a1, 1   # a1 <- 1
   li   a2, 24  # a2 <- 24
   # Print the time starting at row 1 col 24
   jal  printStr     # Uses printStr from displayDemo.S 
   lw   ra, 0(sp)    # Restore ra 
   addi sp, sp, 4    # Restore stack pointer
   jalr zero, ra, 0  # Return to caller

#---------------------------------------------------------------------------------------------
# checkApple
# After the snake moves forward by one unit, this function can be called to check if the snake is able 
# to eat the current apple. If it is then update the timer and score
# 
# Args:
#   None
#
# Register Usage
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#   t3: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
checkApple:
	addi sp, sp, -4    # Make room on stack for 1 item
	sw   ra, 0(sp)     # Save ra onto stack
	la   t0, appleRow  # t0 <- Addr[appleRow]
	lw   t0, 0(t0)     # t0 <- appleRow
	la   t1, positions # t1 <- Addr[positions]
	lbu  t1, 0(t1)  	 # t1 <- row of snake head
	bne  t1, t0, appleExit # If the appleRow and snake head row are not equal, then the snake
	# hasn't eaten the apple, branch to appleExit
	la   t0, appleCol  # t0 <- Addr[appleCol]
	lw   t0, 0(t0)     # t0 <- appleCol
	la   t1, positions # t1 <- Addr[positions]
	lbu  t1, 1(t1)     # t1 <- col of snake head
	bne  t1, t0, appleExit # If the appleCol and snake head col are not equal, then the snake
	# hasn't eaten the apple, branch to appleExit
	jal  drawNewApple  # Else the snake has eaten the apple, branch to drawNewApple to generate a new apple

	la   t0, userPoints # t0 <- Addr[userPoints]
	lbu  t1, 2(t0)      # t1 <- right digit
	addi t1, t1, 1      # right digit + 1
	li   t2, 0x39       # t2 <- 0x39 (ASCII 9)
	bgt  t1, t2, pointsZeroThird # If adding 1 to the digit made it bigger than 9 then we have a carry, branch to
	# pointsZeroThird label
	sb   t1, 2(t0)  # Else there is no carry, just store the incremented digit back into memory
	j    changeTime # Jump to changeTime label

	# There is a carry from the right digit check to see if there is another carry for the middle digit or not
	pointsZeroThird:
		lbu  t1, 1(t0)  # t1 <- right digit
		beq  t1, t2, pointsZeroSecond # If right digit is 9 then there will be carry, branch to pointsZeroSecond
		addi t1, t1, 1  # Else there is no carry for middle digit, just add 1 to the digit
		sb   t1, 1(t0)  # Store the incremented digit back into memory
		li   t2, 0x30   # t2 <- 0x30 (ASCII 0)
		sb   t2, 2(t0)  # Store 0 into the right digit position
		j    changeTime # Jump to changeTime label

	# There is a carry from the right and middle digits, add 1 to the left digit and set the right and middle digits to 0	
	pointsZeroSecond:
		lbu  t1, 0(t0)  # t1 <- left digit
		addi t1, t1, 1  # Increment left digit by 1
		sb   t1, 0(t0)  # Store incremented digit back into memory
		li   t2, 0x30   # t2 <- 0x30 (ASCII 0)
		sb   t2, 1(t0)  # Set middle digit to 0
		sb   t2, 2(t0)  # Set right digit to 0
		j    changeTime # Jump to changeTime label

	# The apple has been eaten so we need to add the bonus time to the timer
	changeTime:
		la   t0, initialTime # t0 <- Addr[initialTime]
		lbu  t1, 2(t0)	 # t1 <- right digit
		la   t2, bonusTime # t2 <- Addr[bonusTime]
		lw   t2, 0(t2)  # t2 <- bonusTime
		add  t1, t1, t2 # t1 <- t1 + bonusTime
		li   t3, 0x39   # t3 <- 0x39 (ASCII 9)
		bgt  t1, t3, carry # If adding the bonus time caused the time to be greater than 0x39 then there is a carry
		sb   t1, 2(t0) # Else there is no carry, store the incremented right digit back into memory
		j    appleExit # Jump to appleExit

		# There is a carry from right digit, determine if there is also a carry for middle digit
		carry:
			li   t3, 0x3A   # t3 <- 0x3A
			lbu  t1, 2(t0)  # t1 <- right digit
			sub  t1, t3, t1 # t1 <- 0x3A - right digit
			sub  t1, t2, t1 # t1 <- bonusTime - (0x3A - right digit)
			li   t2, 0x30   # t2 <- 0x30 (ASCII 0)
			add  t1, t1, t2 # t1 <- t1 + 0x30
			sb   t1, 2(t0)  # Store the incremented right digit into memory
			lbu  t1, 1(t0)  # t1 <- middle digit
			addi t1, t1, 1  # Middle digit + 1
			beq  t1, t3, doubleCarry # If adding 1 to the middle digit caused it to be greater than 0x39 then the middle
			# digit also has a carry, branch to doubleCarry label
			sb   t1, 1(t0)  # Else there is no carry on middle digit, store the incremented middle digit into memory
			j    appleExit  # Jump to appleExit

		# The middle digit also has a carry, set the middle digit to 0 and add 1 to the right digit
		doubleCarry:
			li   t1, 0x30  # t1 <- 0x30 (ASCII 0)
			sb   t1, 1(t0) # Store 0 into middle digit
			lbu  t1, 0(t0) # t1 <- left digit
			addi t1, t1, 1 # Add 1 to left digit
			sb   t1, 0(t0) # Store incremented left digit back into memory
			j    appleExit # Jump to appleExit

 	# The timer and score have been updated, restore the stack and return to caller
	appleExit:
		lw   ra, 0(sp)   # Restore ra
		addi sp, sp, 4   # Restore stack pointer
		jalr zero, ra, 0 # Return to caller

#---------------------------------------------------------------------------------------------
# checkHit
# After the snake moves forward by one unit, this function can be called to check if the snake hits a wall
# If so set the endGame flag to 1
# 
# Args:
#   None
#
# Register Usage
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
checkHit:
	la   t0, positions # t0 <- Addr[positions]
	lbu  t1, 0(t0)   # t1 <- row of the snake head
	lbu  t0, 1(t0)   # t0 <- col of the snake head
	li   t2, 0       # t2 <- 2
	beq  t0, t2, hitWall # If the snake head is at col 0 then the snake hit the wall, branch to hitWall
	beq  t1, t2, hitWall # If the snake head is at row 0 then the snake hit the wall, branch to hitWall
	li   t2, 10      # t2 <- 10
	beq  t1, t2, hitWall # If the snake head is at row 10 then the snake hit the wall, branch to hitWall
	li   t2, 20      # t2 <- 20
	beq  t0, t2, hitWall # If the snake head is at col 20 then the snake hit the wall, branch to hitWall
	# Else the snake hasn't hit a wall, return to caller
	jalr zero, ra, 0 # Return to caller

	# The snake has hit a wall, set endGame flag to 1 and return to caller
	hitWall:
		la   t0, endGame # t0 <- Addr[endGame]
		li   t1, 1       # t1 <- 1
		sw   t1, 0(t0)   # Set endGame to 1
		jalr zero, ra, 0 # Return to caller

#---------------------------------------------------------------------------------------------
# checkTime
# Checks to see if the time has hit zero, if so set the endGame flag to 1
# 
# Args:
#   None
#
# Register Usage
#   t0: Acts as a temporary variable that stores addresses, immediates and words
#   t1: Acts as a temporary variable that stores addresses, immediates and words
#   t2: Acts as a temporary variable that stores addresses, immediates and words
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
checkTime:
	la   t0, initialTime # t0 <- Addr[initialTime]
	li   t1, 0x30    # t1 <- 0x30 (ASCII 0) 
	lbu  t2, 2(t0)   # t2 <- right digit
	bne  t2, t1, timeLeft # If right digit is not 0 then there is still time
	lbu  t2, 1(t0)   # t2 <- middle digit
	bne  t2, t1, timeLeft # If middle digit is not 0 then there is still time
	lbu  t2, 0(t0)   # t2 <- left digit
	bne  t2, t1, timeLeft # If left digit is not 0 then there is still time
	# Else all the digits equal 0, there is no more time, set the endGame flag to 0
	la   t0, endGame # t0 <- Addr[endGame]
	li   t1, 1       # t1 <- 1
	sw   t1, 0(t0)   # Set endGame flag to 1
	jalr zero, ra, 0 # Return to caller

	# There is still time left, return to caller
	timeLeft:
		jalr zero, ra, 0 # Return to caller

#---------------------------------------------------------------------------------------------
# printAllWalls
#
# Subroutine description: This subroutine prints all the walls within which the snake moves
# 
#   Args:
#  		None
#
# Register Usage
#      s0: the current row
#      s1: the end row
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printAllWalls:
	# Stack
	addi   sp, sp, -12
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	# print the top wall
	li     a0, 21
	li     a1, 0
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	li     s0, 1	# s0 <- startRow
	li     s1, 10	# s1 <- endRow
printAllWallsLoop:
	bge    s0, s1, printAllWallsLoopEnd
	# print the first brick
	la     a0, Brick	# a0 <- address(Brick)
	lbu    a0, 0(a0)	# a0 <- '#'
	mv     a1, s0		# a1 <- row
	li     a2, 0		# a2 <- col
	jal    ra, printChar
	# print the second brick
	la     a0, Brick
	lbu    a0, 0(a0)
	mv     a1, s0
	li     a2, 20
	jal    ra, printChar
	
	addi   s0, s0, 1
	jal    zero, printAllWallsLoop

printAllWallsLoopEnd:
	# print the bottom wall
	li     a0, 21
	li     a1, 10
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	addi   sp, sp, 12
	jalr   zero, ra, 0


#---------------------------------------------------------------------------------------------
# printMultipleSameChars
# 
# Subroutine description: This subroutine prints white spaces in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
# 
#   Args:
#   a0: length of the chars
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#   a3: char to print
#
# Register Usage
#      s0: the remaining number of cahrs
#      s1: the current row
#      s2: the current column
#      s3: the char to be printed
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printMultipleSameChars:
	# Stack
	addi   sp, sp, -20
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	sw     s3, 16(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2
	mv     s3, a3

# the loop for printing the chars
printMultipleSameCharsLoop:
	beq    s0, zero, printMultipleSameCharsLoopEnd   # branch if there's no remaining white space to print
	# Print character
	mv     a0, s3	# a0 <- char
	mv     a1, s1	# a1 <- row
	mv     a2, s2	# a2 <- col
	jal    ra, printChar
		
	addi   s0, s0, -1	# s0--
	addi   s2, s2, 1	# col++
	jal    zero, printMultipleSameCharsLoop

# All the printing chars work is done
printMultipleSameCharsLoopEnd:	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	lw     s3, 16(sp)
	addi   sp, sp, 20
	jalr   zero, ra, 0


#------------------------------------------------------------------------------
# printStr
#
# Subroutine description: Prints a string in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
#
# Args:
# 	a0: strAddr - The address of the null-terminated string to be printed.
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#
# Register Usage
#      s0: The address of the string to be printed.
#      s1: The current row
#      s2: The current column
#      t0: The current character
#      t1: '\n'
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printStr:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

# the loop for printing string
printStrLoop:
	# Check for null-character
	lb     t0, 0(s0)
	# Loop while(str[i] != '\0')
	beq    t0, zero, printStrLoopEnd

	# Print Char
	mv     a0, t0
	mv     a1, s1
	mv     a2, s2
	jal    ra, printChar

	addi   s0, s0, 1	# i++
	addi   s2, s2, 1	# col++
	jal    zero, printStrLoop

printStrLoopEnd:
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0



#------------------------------------------------------------------------------
# printChar
#
# Subroutine description: Prints a single character to the Keyboard and Display MMIO Simulator terminal
# at the given row and column.
#
# Args:
# 	a0: char - The character to print
#	a1: row - The row to print the given character
#	a2: col - The column to print the given character
#
# Register Usage
#      s0: The character to be printed.
#      s1: the current row
#      s2: the current column
#      t0: Bell ascii 7
#      t1: DISPLAY_DATA
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printChar:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	# save parameters
	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

	jal    ra, waitForDisplayReady

	# Load bell and position into a register
	addi   t0, zero, 7	# Bell ascii
	slli   s1, s1, 8	# Shift row into position
	slli   s2, s2, 20	# Shift col into position
	or     t0, t0, s1
	or     t0, t0, s2	# Combine ascii, row, & col
	
	# Move cursor
	lw     t1, DISPLAY_DATA
	sw     t0, 0(t1)
	jal    waitForDisplayReady	# Wait for display before printing
	
	# Print char
	lw     t0, DISPLAY_DATA
	sw     s0, 0(t0)
	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0

#------------------------------------------------------------------------------
# waitForDisplayReady
#
# Subroutine description: A method that will check if the Keyboard and Display MMIO Simulator terminal
# can be writen to, busy-waiting until it can.
#
# Args:
# 	None
#
# Register Usage
#      t0: used for DISPLAY_CONTROL
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
waitForDisplayReady:
	# Loop while display ready bit is zero
	lw     t0, DISPLAY_CONTROL
	lw     t0, 0(t0)
	andi   t0, t0, 1
	beq    t0, zero, waitForDisplayReady
	jalr   zero, ra, 0
