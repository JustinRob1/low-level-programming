#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2020 Quinn Pham
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
# Lab-PacketForward-Checksum
# Author: Quinn Pham
# Date: July, 23 2020
#
# Adapted from:
# Lab- Reverse Polish Notation Calculator
# Author: Kristen Newbury
# Date: August 9 2017
#
# RISC-V Modifications 
# Author: Abdulrahman Alattas
# Date: May 2, 2019
#
# Adapted from:
# Control Flow Lab - Student Testbed
# Author: Taylor Lloyd
# Date: July 19, 2012
#
# This code loads an IP packet from the file specified by the path in the
# program argument into memory and calls checksum with the starting address 
# of the IP packet as the argument.
#
#-------------------------------

#-------------------start of comman file-----------------------------------------------

.data
packet:		.space 	128
packetFileName:	.space	64
noFileStr:	.asciz "Couldn't open specified file.\n"

.align 2

.text 

main:
    lw	a0, 0(a1)	# Put the filename pointer into a0
    li	a1, 0		# Flag: Read Only
    li	a7, 1024	# Service: Open File
    ecall			# File descriptor gets saved in a0 unless an error happens

    bltz	a0, main_err    # Negative means open failed
    
    la	a1, packet	# write into my binary space
    li	a2, 2048        # read a file of at max 2kb
    li	a7, 63          # Read File Syscall
    ecall

    la	a0, packet	# a0 <- Addr[packet]
    jal	checksum	# a0 <- checksum(Addr[packet])
    li	a7, 34		# a7 <- 34
    ecall			# PrintIntHex(checksum(Addr[packet]))

    li	a0, 0xA		# a0 <- '\n'
    li	a7, 11		# a7 <- 11
    ecall 			# printChar('\n')

    j	main_done
    
main_err:
    la	a0, noFileStr   # print error message in the event of an error when trying to read a file
    li	a7, 4           # the number of a system call is specified in a7
    ecall             	# Print string whose address is in a0
    
main_done:
   
    li      a7, 10          # ecall 10 exits the program with code 0
    ecall

#-------------------end of common file-------------------------------------------------

