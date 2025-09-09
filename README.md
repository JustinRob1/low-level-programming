# Low-Level Programming

This repository showcases a collection of low-level programming projects and exercises written primarily in RISC-V assembly language. The code demonstrates a range of computer organization, architecture, and systems programming concepts, and practical implementation.

## Repository Structure

- **exercises/**  
  A set of focused RISC-V assembly exercises covering exception handling, bit manipulation, and array operations. Each file is designed to illustrate a specific low-level concept.

- **projects/**  
  Contains larger, self-contained projects that implement classic algorithms, data structures, and interactive applications in assembly:
  - **credit-card-validator/**  
    Implements credit card validation using the Luhn algorithm, including card type detection and file-based input/output.
  - **hash-table/**  
    A complete hash table implementation supporting insertion, lookup, deletion, and collision handling with string keys.
  - **intro-programs/**  
    Introductory assembly programs for string manipulation, argument handling, and debugging, suitable for beginners.
  - **packet-checksum/**  
    Calculates the checksum of IP packet headers, demonstrating file I/O and bitwise operations.
  - **snake-game/**  
    An interactive Snake game using RISC-V assembly, featuring real-time keyboard input, display output, and game logic.
  - **string-interning/**  
    Implements a string interning system with a hash table, supporting efficient storage and retrieval of unique strings.

## Purpose

The purpose of this repository is to demonstrate proficiency in low-level programming and computer architecture concepts, including:
- Direct memory manipulation and system calls
- Implementation of algorithms and data structures at the assembly level
- Handling of input/output, exceptions, and interrupts
- Interactive and file-based program design in a resource-constrained environment

Each project and exercise is accompanied by documentation and test cases to facilitate understanding and reproducibility.

## Getting Started

All code is intended to be run in the [RARS](https://github.com/TheThirdOne/rars) RISC-V simulator.  
Refer to the individual project and exercise README files for detailed instructions on building, running, and testing each component.
