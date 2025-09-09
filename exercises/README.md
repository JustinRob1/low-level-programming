# RISC-V Assembly Exercises

## Overview

This directory contains a collection of RISC-V assembly exercises that demonstrate exception handling, bit manipulation, and array updates. Each file focuses on a specific low-level programming concept, providing practical examples for learning and experimentation.

## Problem Summary

The exercises in this directory cover:
- Handling exceptions and timer interrupts.
- Flipping a specific bit in a byte stored in memory.
- Updating an array based on values from other arrays and a global index.

## Assumptions

- All programs are intended to be run in the [RARS](https://github.com/TheThirdOne/rars) RISC-V simulator.
- Inputs (such as memory contents and global variables) are set up in the data segment or by the caller as described in each file's comments.
- For `UpdateY.s`, the global variable `i` (in `s0`) must be initialized before calling.

## How to Run

Open the desired `.s` file in RARS and run the program.  
For example, to run `flipBitInByte.s` from the command line:

```
rars nc flipBitInByte.s
```

## File Descriptions

- **[Exceptions.s](Exceptions.s)**  
  Implements an exception and interrupt handler. Handles timer interrupts by incrementing a `seconds` counter and terminates the program for unhandled exceptions, printing debug messages.

- **[flipBitInByte.s](flipBitInByte.s)**  
  Defines the `flipBitInByte` subroutine, which flips a specified bit in a byte at a given memory address.

- **[UpdateY.s](UpdateY.s)**  
  Implements the `UpdateY` subroutine, which updates elements of array `Y` by adding values from array `X` indexed by `col`, for a range determined by array `A` and a global index `i`.
