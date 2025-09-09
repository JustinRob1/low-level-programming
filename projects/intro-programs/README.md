# Introductory RISC-V Assembly Programs

## Overview

This lab contains several introductory RISC-V assembly programs designed to teach basic concepts such as string manipulation, argument handling, and debugging. Each program demonstrates a different aspect of assembly programming and provides hands-on experience with memory, loops, and system calls.

## Problem Summary

The programs in this lab cover the following tasks:
- Copying and printing strings.
- Reversing and checking for palindromes.
- Removing extra spaces from strings.
- Handling and printing program arguments in reverse.
- Practicing with bitwise and arithmetic operations.

## Assumptions

- All programs are intended to be run in the [RARS](https://github.com/TheThirdOne/rars) RISC-V simulator.
- Input strings are null-terminated and stored in the data segment.
- For the arguments program, command-line arguments are provided via the RARS interface.

## How to Run

Open the desired `.s` file in RARS and run the program.  
For `lab1-arguments.s`, provide a string argument in the RARS "Program Arguments" field before running.

Example console command (if using RARS command line):

```
rars nc lab1-hello.s
```

## File Descriptions

- **[lab1-hello.s](lab1-hello.s)**  
  Copies a string from one memory location to another and prints it to the console.

- **[lab1-debugPalindrome.s](lab1-debugPalindrome.s)**  
  Checks if a given string is a palindrome and prints the result.

- **[lab1-broken.s](lab1-broken.s)**  
  Removes extra spaces from a string, ensuring only single spaces remain between words.

- **[lab1-arguments.s](lab1-arguments.s)**  
  Reads a string argument and prints it in reverse order.

- **[test.s](test.s)**  
  Contains simple bitwise and arithmetic operations for testing and practice.
