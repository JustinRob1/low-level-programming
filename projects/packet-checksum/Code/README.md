# Packet Forwarding Checksum (RISC-V Assembly)

## Overview

This project implements an IP packet header checksum calculator in RISC-V assembly. The checksum is computed according to the standard Internet checksum algorithm, which is used to verify the integrity of IP packet headers in network communication.

## Problem Summary

Given a binary file containing an IP packet, the program:
- Loads the packet into memory.
- Calculates the checksum of the IP header, skipping the checksum field itself.
- Outputs the computed checksum in hexadecimal format.

The checksum is calculated by summing all 16-bit halfwords in the header (with the checksum field set to zero), adding any carry bits, and then taking the one's complement of the result.

## Assumptions

- Input files are valid binary representations of IP packets generated using the provided packet generator.
- The program is run in the [RARS](https://github.com/TheThirdOne/rars) RISC-V simulator.
- The maximum packet size is 128 bytes.
- The checksum is output in hexadecimal format.

## How to Run

1. Assemble the code in RARS with the following command (replace `examplePacket.in` with your packet file):

   ```
   rars nc common.s checksum.s examplePacket.in
   ```

   Or, if running interactively in RARS:
   - Open both `common.s` and `checksum.s`.
   - Provide the packet file as a program argument.

2. The program will print the checksum of the packet header.

## File Descriptions

- **[common.s](common.s)**  
  Loads the packet from a file, calls the checksum routine, and prints the result.

- **[checksum.s](checksum.s)**  
  Implements the checksum calculation logic, including byte-swapping and header length extraction.

- **[packetGenerator.c](packetGenerator.c)**  
  C utility to generate test IP packet files with customizable header fields and valid/invalid checksums.

- **examplePacket.in**  
  Example binary IP packet file for testing (not included here, but referenced in lab instructions).
