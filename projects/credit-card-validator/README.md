# Credit Card Validator (RISC-V Assembly)

## Overview

This project implements a credit card number validator in RISC-V assembly, using Luhn's algorithm to determine the validity and type of a credit card number. The program reads a credit card number from a file, processes it, and outputs both the card type and a modified array of digits as per the assignment requirements.

## Problem Summary

Given a credit card number as a sequence of digits, the program must:
- Validate the number using Luhn's algorithm.
- Identify the card type (Visa, MasterCard, Diner's Club, Chase Visa, Unknown, or Invalid).
- Output the card type and the modified digit array after processing.

## Assumptions

- Input files contain only the credit card number (digits) on a single line.
- The input number is formatted as a sequence of ASCII digits with no spaces or special characters.
- The program is run in a RISC-V simulator such as RARS.
- The output consists of two lines: the card type and the modified digit array.

## File Descriptions

- **common.s**  
  Main driver code. Handles reading the input file, converting ASCII digits to integers, calling the validation routine, and printing results.

- **creditValid.s**  
  Implements the Luhn algorithm and card type detection. Processes the digit array and writes the modified array to memory.

- **example.s**  
  Example code demonstrating number-to-string conversion and system call usage in RISC-V assembly.

- **tests/**  
  Contains sample input files for testing different card types.

## How to Run

1. Open a terminal in the `Code` directory.
2. Assemble and run the program in RARS, providing the input file as an argument. For example:

```
rars nc common.s creditValid.s example.s master.txt
```

3. The output will display the card type and the modified digit array:
```
MasterCard
1199999999999991
```