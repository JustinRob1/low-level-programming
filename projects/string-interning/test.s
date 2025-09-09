#---------------------------------------------------------------
# Student Test File for Interning Lab
# Author: Taylor Lloyd
# Date: July 12, 2012
#---------------------------------------------------------------
#---------------------------------------------------------------
# Conversion To RISC-V: Mehrab Mehdi Islam
# Date: July 01, 2019
#---------------------------------------------------------------


#-------------------------------------------
# Bug fixing - Nov 23, 2014
# 
# Author: Alejandro Ramirez
# 
# Added a check to avoid problems
# with strings that have not been
# interned. 
#
#-------------------------------------------

#-------------------------------------------
# Bug fixing - December 02, 2019
#
# Author: J. Nelson Amaral
#
# File was not closing properly because the
# value of a0 in the environment call was not
# the file descriptor.
#
#-------------------------------------------

.data

instructions:
	.asciz	"Enter 'i' to intern, 'g' to retrieve, 'f' to intern a file, 'q' to quit:"
internText:
	.asciz	"String to intern:"
internReturn:
	.asciz "Identifier:"
fInternText:
	.asciz	"File to intern:"
sErr:
	.asciz "String has not been interned.\n"
fErr:
	.asciz "Error opening file.\n"
fInternReturn:
	.asciz "Identifiers:\n"
zeroIdentifiers:
    .asciz "Zero strings interned.\n"
getText:
	.asciz	"Identifier to retrieve:"
getReturn:
	.asciz "String:"
err:	.asciz "Unrecognized command.\n"
nlStr:	.asciz "\n"
cmd:	.space 256
	.align 2
fileMem:.space 2048

.text
main:
	mainLoop:
		#instructions message
		la	a0, instructions
		li	a7, 4
		ecall

		#read input
		la	a0, cmd
		li	a1, 16
		li	a7, 8
		ecall

		#intern?
		lb	t0, cmd
		li	t1, 'i'
		beq	t0, t1, intern

		#file intern?
		lb	t0, cmd
		li	t1, 'f'
		beq	t0, t1, file

		#retrieve?
		li	t1, 'g'
		beq	t0, t1 get

		#quit?
		li	t1, 'q'
		beq	t0, t1, die

		#error & loop back
		la	a0, err
		li	a7, 4
		ecall
		j	mainLoop

	intern:
		#prompt
		la	a0, internText
		li	a7, 4
		ecall
		
		#allocate space for string
		li	a0, 256
		li	a7, 9
		ecall

		#read string to newly allocated space
		li	a1, 256
		li	a7, 8
		ecall
		mv	s0, a0

		#drop newline from end
		li	t0, 0x0A
		mv	t1, s0
		intern_drop_nl:
			lb	t2, 0(t1)
			beqz	t2, intern_drop_done
			beq	t0, t2, intern_store
			addi	t1, t1, 1
			j	intern_drop_nl
		intern_store:
			sb	zero, 0(t1)
		intern_drop_done:

		#prettify
		la	a0, internReturn
		li	a7, 4
		ecall

		#call internString
		mv	a0, s0
		jal	internString

		#print identifier
		#mv	a0, a7
		li	a7, 1
		ecall

		#print newline
		la	a0, nlStr
		li	a7, 4
		ecall

		j	mainLoop
	file:
		#prompt
		la	a0, fInternText
		li	a7, 4
		ecall

		#read filename
		la	a0, cmd
		li	a1, 256
		li	a7, 8
		ecall
		
		#drop newline from end
		li	t0, 0x0A
		la	t1 cmd
		file_drop_nl:
			lb	t2, 0(t1)
			beqz	t2, file_drop_done
			beq	t0, t2, file_store
			addi	t1, t1, 1
			j	file_drop_nl
		file_store:
			sb	zero, 0(t1)
		file_drop_done:
		

		li	a1, 0		    # open file with read-only flag
		li	a2, 0x0644
		li	a7, 1024
		ecall
        mv t2, a0           # t2 <- file descriptor
	
		li	t0, -1
		beq	a0, t0, printFileErr

		
        la	a1, fileMem
        li	a2, 2048        # a2 <- maximum length to read
        li	a7, 63          # read file content to memory
		ecall

		#Place EOT at end of file
        add	t0, a1, a0  # fileMem + number of characters read
		li	t1, 4	    # t1 <- EOT
        sb	t1, 0(t0)

		#Close file
        mv a0, t2           # a0 <- file descriptor
		li	a7, 57
		ecall

		#prettify
		la	a0, fInternReturn
		li	a7, 4
		ecall

		#call internFile
		la	a0, fileMem
		jal	internFile
		bnez  a1, printIdentifiers
        la    a0, zeroIdentifiers
        li    a7, 4
        ecall
        j     mainLoop

        printIdentifiers:

		#print all identifiers
		mv	t0, a0
		mv	t1, a1
		fileIDPrint:
			lw	a0, 0(t0)
			li	a7, 1
			ecall

			#print newline
			la	a0, nlStr
			li	a7, 4
			ecall
			
			addi	t0, t0, 4
			addi	t1, t1, -1

			bgtz	t1, fileIDPrint

		j	mainLoop

	get:
		#prompt
		la	a0, getText
		li	a7, 4
		ecall

		#read number
		li	a7, 5
		ecall
		mv	s0, a0

		#prettify
		la	a0, getReturn
		li	a7, 4
		ecall

		#call getInternedString
		mv	a0, s0
		jal	getInternedString

		#check if it is not zero
		beqz 	a0, printStringErr 

		#print it
		#mv	a0, a7
		li	a7, 4
		ecall

		#print newline
		la	a0, nlStr
		li	a7, 4
		ecall

		j	mainLoop

	printStringErr: 
		la	a0, sErr
		li 	a7, 4
		ecall
		j 	mainLoop

	printFileErr:
		la	a0, fErr
		li	a7, 4
		ecall
		j	mainLoop

	die:
		li	a7, 10
		ecall
		
######################## STUDENT CODE BEGINS HERE ##########################
