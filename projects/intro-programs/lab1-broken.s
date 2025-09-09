#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2018 University of Alberta
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
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
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
#------------------------------
# Intro Lab - Broken Program
# Author: Quinn Pham
# Date: May 14, 2020
#
# Something doesn't work. This code should print
# the string in Str without extra spaces.
#
# examples:
# "My    spacebar   is broken!"     ->  "My spacebar is broken!"
# "hello                 world"     ->  "hello world"
# "           RISC-V          "     ->  " RISC-V "    
#
# The string address is in s0
# Trimmed string address is in s1
# ASCII space character ' ' is in s2
# Loaded characters are temporarily stored in t0
#------------------------------

.data
Trimmed:    	.space 64
Str:		.asciz "h   i"
spaceChar:	.byte  0x20


.text
main:
    la		s0, Str
    la		s1, Trimmed
    la		s2, spaceChar
    lbu		s2, 0(s2)
    
    lbu		t0, 0(s0)
    sb		t0, 0(s1)
    beqz	t0, doneCopy
    beq		t0, s2, spaceLoop
copyLoop:
	addi		s0, s0, 1
	addi 		s1, s1, 1
	lbu		t0, 0(s0)
	sb		t0, 0(s1)
	beqz		t0, doneCopy
	bne		t0, s2, copyLoop
spaceLoop:
	lbu		t0, 1(s0)
	bne		t0, s2, copyLoop 
	addi		s0, s0, 1
	j		spaceLoop
	
doneCopy:
    la		a0, Trimmed
    li		a7, 4
    ecall

    li  	a7, 10
    ecall
    
