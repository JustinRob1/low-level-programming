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

.text

#------------------------------------------------------------------------------
# main_playground
# This function runs the playground function and displays a representation of
# the hash table.
# 
# Register Usage:
#   a0/a7: function and ecall arguments
#-----------------------------------------------------------------------------
main_playground:

    # initalize alloc pointer
    la t0, alloc_pointer  # load address to alloc pointer 
    la t1, alloc_buffer # load address to alloc space
    sw t1, 0(t0) # save pointer to alloc space in alloc_pointer

    # run student playground
    la a0, test_array
    jal playground

    # display array
    la a0, test_array
    jal test_print_array
    
    # exit program
    li a7, 10
    ecall

.include "hashtable.s"