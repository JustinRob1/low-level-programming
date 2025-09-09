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

.include "common_playground.s"
.data
.align 2

input_1: .asciz "CMPUT 229"
# --- add more strings as necessary ---

.text
#------------------------------------------------------------------------------
# playground
# This function tests your code and displays a representation of the hash table.
#
# Args:
#	a0: pointer to hash table (storearray)
#-----------------------------------------------------------------------------
playground:

    # save registers
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0 # the pointer to storearray is stored in s0

    # --- test your code for part 2 (insert, find, delete) here ---

    # --- use the following example to insert a value ---
    # mv a0, s0
    # la a1, input_1
    # li a2, 154
    # jal insert

    # restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8

    ret
