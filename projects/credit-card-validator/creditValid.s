#----------------------------------------------------------------
#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2022 <Justin Robertson>
#
# Unauthorized redistribution is forbidden in all circumstances. Use of this
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
# Name: Justin Robertson                 
# Lecture Section: A1   
# Instructor: Matthew Gaudet           
# Lab Section: D01          
# Teaching Assistants: Islam Ali, Mostafa Yadegari
#---------------------------------------------------------------

.data
.align 2
	vector: 					#vector is an array of digits "455953"
		.word 4
		.word 5
		.word 5
		.word 9
		.word 5
		.word 3


.text
.include "common.s"

# -----------------------------------------------------------------------------
# creditValid: 
# 	This function decides if a given card number is a valid credit-card number using Luhn's algorithm 
# 	and saves a modified array in memory reserved by a2. A value is then stored in a0 indicating the
# 	type of the card or if the card is unknown or invalid
#
# Arguments:
# 	a0: Contains pointer to the array of digits (32-bit integers) of a credit card number
# 	a1: Contains length of the array stored in a0
#	a2: Contains space reserved to store the modified array of digits
# 
# Return Values:
# 	a0: A number that indicates the type of credit card or if a credit card is invalid or unknown
#
# Side Effects:
#		None

# Register Usage:
#  		t0: Stores the digits loaded from the array a0
#		t1: Stores the address of the digits from the array a0
#		t2  Stores the value of the digits that are doubled and sums
# 		t3: The temporary variable i that stores the current index for the loops
# 		t4: Acts as a temporary variable that stores digits, addresses, sums and immediates
# 		t5: Acts as a temporary variable that stores digits, addresses, sums and immediates
# 		t6: Acts as a temporary variable that stores digits, addresses, sums and immediates
#       s1: Stores the value 1 which is used to increment and decrement i
#  		s2: Stores the value 2 which is used to double numbers and acts as a loop bound
# 		s3: Stores the value 10 which is used to check if a doubled number is two digits; 
#           used for the mod operator
# -----------------------------------------------------------------------------

creditValid:
	# Preform pre-loop instructions, load and store the first
	# element of the array and set immediates
	li 			s1, 1  	   # s1 <- 1  (j = 1) 
	li          s2, 2	   # s2 <- 2  
	li   		s3, 10     # s3 <- 10 

	# To double every second digit starting from the rightmost digit
	# we need to start from the i - 1 element in the array
	# Load and store the right most digit from the array a0 into the array a2
	sub 		t3, a1, s1 # i = len(a0) - 1
	slli 		t1, t3, 2  # t1 <- i * 4
	add 		t1, t1, a0 # t1 <- Addr(a0[i])
	slli        t5, t3, 2  # t5 <- i * 4
	add 		t5, t5, a2 # t5 <- Addr(a2[i])
	lw 			t0, 0(t1)  # t0 <- a0[i]
	sw 			t0, 0(t5)  # a2[i] <- t0
	add 		t4, t4, t0 # t4 <- 0 + a0[i] (Continuous sum of all the numbers stored in the array a2)
		
	# Starting at the second rightmost number in the array, this loop will double
	# every other number, if doubling a number results in a two digit number
	# the loop will branch to the label double. The loop will iterate through all the digits
	# going from the right most digit to the left most digit. All the numbers are then stored
	# in the array a2 starting from the right most number. The numbers are also
	# added to the continuous sum stored in t4		
	loop:
		sub 		t3, t3, s1 # i <- i - 1
		bltz        t3, check  # If i < 0, we have loaded every element from a0, branch to check label
		slli 		t1, t3, 2  # t1 <- i * 4
		add 		t1, t1, a0 # t1 <- Addr(a0[i])
		slli        t5, t3, 2  # t5 <- i * 4
		add 		t5, t5, a2 # t5 <- Addr(a2[i])
		lw 			t0, 0(t1)  # t0 <- a0[i]
		mul			t0, t0, s2 # t0 <- t0 * 2
		bge 		t0, s3, double # Branch to double label if a0[i] >= 10
		# If t0 < 10, the doubled number is just single digit so we just store it in a2
		sw 			t0, 0(t5)  # a2[i] <- t0

		# The next digit in the number does not have to be doubled, so we just increment the 
		# counter and store the digit in the array a2
		add 		t4, t4, t0 # t4 <- 0 + a0[i]
		sub 		t3, t3, s1 # i <- i - 1
		bltz        t3, check  # If i < 0, we have loaded every element from a0, branch to check
		slli 		t1, t3, 2  # t1 <- i * 4
		add 		t1, t1, a0 # t1 <- Addr(a0[i])
		slli        t5, t3, 2  # t5 <- i * 4
		add 		t5, t5, a2 # t5 <- Addr(a2[i])
		lw 			t0, 0(t1)  # t0 <- a0[i]
		sw 			t0, 0(t5)  # a2[i] <- t0
		add 		t4, t4, t0 # t1 <- t4 <- 0 + a0[i]
		bge 		t3, zero, loop # if i >= 0 continue loop

	# This loop adds together the digits of the two digit numbers
	# and stores the result in a2, it also will store the next digit from a0
	# into a2 since it does not need to be doubled 
	double:
		# Every double digit number must have 1 as the first digit
		rem 		t0, t0, s3 # Sets t0 to the second digit of the doubled number (t0 <- t0 mod 10)
		addi 		t0, t0, 1  # t0 <- t0 + 1
		sw 			t0, 0(t5)  # a2[i] <- t0 
		add 		t4, t4, t0 # t4 <- 0 + t0
		sub 		t3, t3, s1 # i <- i - 1
		bltz        t3, check  # If i < 0, we have loaded every element from a0, branch to check
		slli 		t1, t3, 2  # t1 <- i * 4
		add 		t1, t1, a0 # t1 <- Addr(a0[i])
		slli        t5, t3, 2  # t5 <- i * 4
		add 		t5, t5, a2 # t5 <- Addr(a2[i])
		lw 			t0, 0(t1)  # t0 <- a0[i]
		sw 			t0, 0(t5)  # a2[i] <- t0
		add 		t4, t4, t0 # t4 <- t4 + a0[i]
		j 		    loop       # Jump to the start of the loop label
		
	# If the sum is divisible by 10 then branch to the valid label
	# If the sum is not divisible by 10, the card number is invalid and branch
	# to the invalid label
	check:
		rem 		t4, t4, s3   # t4 <- t4 mod 10
		beqz 		t4, valid    # If t4 mod 10 = 0, the number is divisible by 10
		bnez 		t4, invalid  # If t4 mod 10 != 0, the number is not divisable by 10, the card is invalid
	
	# Returns the value 0 indicating the credit card is invalid
	# branchs to exit label
	invalid:
		li 	 	a0, 0		# Return a0
		j 		exit		# Jump to exit
			
	# Determines the MII of the credit card and branches to the label corresponding to the 
	# proper MII. If the MII is not one of the listed MII's, the card is unknown, jump
	# to unknown label
	valid: 	 
		div 		t3, zero, t3 	  # Sets i to 0
		slli 		t1, t3, 2   	  # t1 <- i * 4
		add 		t1, t1, a0  	  # t1 <- Addr(a0[i])
		lw 			t0, 0(t1)   	  # t0 <- a0[i]
		li 			t4, 3       	  # t4 <- 3
		beq         t0, t4, dinerMII  # If MII = 3, branch to dinerMII label
		li 			t4, 4             # t4 <- 4 
		beq 		t0, t4, visaMII   # If MII = 4, branch to visaMII label
		li 			t4, 5 		      # t4 <- 5 
		beq 		t0, t4, masterMII # If MII = 5, branch to masterMII label
		j 			unknown			  # The MII is not 3, 4 or 5, the card must be unknown
	
	# Determines if a card number with a MII of 3 is a Diner's Club card
	# or is unknown
	dinerMII: 
		li 		t5, 14		      # t5 <- 14
		div 	t4, zero, t4      # t4 <- 0
		add 	t4, t4, t0        # t4 <- t4 + a0[i]; Keep a sum of the first three digits of the card number 
		beq     a1, t5, dinerLoop # If len(a0) = 14 branch to the dinerLoop
		j 		unknown           # else len(a0) != 14, the card is unknown, jump to unknown label

		# The dinerLoop adds the next two digits of the card number to the sum t4
		dinerLoop:
			add 		t3, t3, s1 # i <- i + 1
			slli 		t1, t3, 2  # t1 <- i * 4
			add 		t1, t1, a0 # t1 <- Addr(a0[i])
			lw 			t0, 0(t1)  # t0 <- a0[i]
			add 		t4, t4, t0 # t4 <- t4 + a0[i]
			blt 		t3, s2, dinerLoop  # If i < 2, continue the dinerLoop
			
		# If t4 - 3 <= 5, then the first three card numbers are in the range 300-305
		li 		t5, 3	   # t5 <- 3
		sub 	t4, t4, t5 # t4 <- t4 - 3
		li 		t5, 5      # t5 <- 5
		bgt 	t4, t5, unknown # If t4 > 5, then the card number is not in the range 
				                # of 300-305 and must be unknown
		li 		a0, 3      # Else the first three card numbers are in the range of 300-305
						   # The card number must be a Diner's Club card, return 3
		j 		exit       # Jump to exit  

	# Determines if a card number with a MII of 4 is a Visa card, Visa Chase card
	# or is unknown
	visaMII:
		la 		    t6, vector       # Loads the address of the vector with the digits 455953
		li 			t2, 13			 # t2 <- 13
		li 			s3, 5			 # s3 <- 5
		beq 		a1, t2, visaLoop # If len(a0) = 13, branch to visaLoop label
		li 			t2, 16           # t2 <- 16
		beq 		a1, t2, visaLoop # If len(a0) = 16, branch to visaLoop label
		j 			unknown 		 # len(a0) != 13 or 16, the card is unknown, jump to unknown label

		# This loop will compare if each digit in the card number matches the digits in the array 455953
		# The first digit does not need to be check since we know the MII is already 4
		visaLoop: 
			add 		t3, t3, s1   	 # i <- i + 1
			slli 		t1, t3, 2     	 # t1 <- i * 4
			add 		t1, t1, a0   	 # t1 <- Addr(a0[i])
			lw 			t0, 0(t1)    	 # t0 <- a0[i]
			slli 		t5, t3, 2    	 # t5 <- i * 4
		    add 		t5, t5, t6   	 # t5 <- Addr(vector[i])
			lw 			t4, 0(t5)    	 # t4 <- vector[i]
			bne 		t0, t4, visa     # If any of the digits do not match then the card must be a Visa 
			blt 		t3, s3, visaLoop # If i < 5, continue the visaLoop
		# If the loop completes then every digit matches, the card is a Chase Visa
		li 		a0, 12		# Return 12
		j 		exit 	    # Jump to exit

	# The card number is a Visa card, return 1 and jump to exit	
	visa:
		li  	a0, 1		# Return 1
		j  		exit 		# Jump to exit
			
	# Determines if a card number with a MII of 5 is a Master Card
	# or is unknown
	masterMII:
		li 		t4, 16		       # t4 <- 16
		beq 	a1, t4, masterSpec # If len(a1) = 16 then branch to masterSpec label
		j 		unknown 		   # Else the card is unknown, jump to unknown label
		
		# Determines if the second digit is 1, 2 or 4
		masterSpec:
			add 		t3, t3, s1   # i <- i + 1
			slli 		t1, t3, 2    # t1 <- i * 4
			add 		t1, t1, a0   # t1 <- Addr(a0[i])
			lw 			t0, 0(t1)    # t0 <- a0[i]
			li 			a0, 2        # Return 2 
			li 			t5, 1 	     # t5 <- 1
			beq 		t0, t5, exit # If second digit equals 1 branch to exit
			li 			t5, 2		 # t5 <- 2
			beq 		t0, t5, exit # If second digit equals 2 branch to exit
			li 			t5, 4 		 # t5 <- 4
			beq 		t0, t5, exit # If second digit equals 4 branch to exit
			j 			unknown 	 # Else the second digit is not 1, 2 or 4 so it must be unknown
		
	# The card is unknown, return 4 and jump to exit
	unknown:
		li 		a0, 4		# Return 4	
		j		exit 		# Jump to exit

	# The function is complete, return to the caller 
	exit:
		jr 		ra 		# Return to common.s
