# String Interning (RISC-V Assembly)

## Overview

This project implements a string interning system in RISC-V assembly. String interning is a method of storing only one copy of each distinct string value, which allows for efficient string comparison and memory usage. The program provides commands to intern strings, retrieve interned strings by identifier, and intern all strings from a file.

## Problem Summary

The goal is to design a system that:
- Interns a string and returns a unique identifier for it.
- Retrieves the original string given its identifier.
- Interns all strings from a file, returning identifiers for each.
- Ensures that identical strings share the same identifier, and different strings have different identifiers, even in the presence of hash collisions.

## Assumptions

- The code is intended to be run in the [RARS](https://github.com/TheThirdOne/rars) RISC-V simulator.
- All input strings are ASCII and null-terminated.
- Input files are plain text and use spaces or newlines to separate words.
- The provided test harness (`test.s`) is used for interactive testing.
- The hash table size and memory allocations are sufficient for the test cases.

## How to Run

To run the tests, use the following command in the `Code` directory:

```
./runTest.sh StringInterning.s
```

Follow the prompts and refer to the test case instructions in the `Tests` folder for sample inputs and expected outputs.

## File Descriptions

- **[StringInterning.s](StringInterning.s)**  
  Main implementation of the string interning system, including the hash table, interning logic, retrieval, and file interning routines.

- **[test.s](test.s)**  
  Interactive test harness that provides a menu for interning, retrieving, and file-based interning of strings.

- **[runTest.sh](runTest.sh)**  
  Shell script to combine the test harness and lab file, then run them in RARS for testing.

- **[Tests/](Tests/)**  
  Contains sample input files and detailed test case descriptions for validating the implementation.
