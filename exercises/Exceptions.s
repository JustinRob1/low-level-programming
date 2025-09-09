.data
 seconds: .word  100
.text
   #------------------------------------------------------------------------------
   # handler determines whether there is an exception or and interrupt and will
   # handler timer interrupts and branch to handlerTerminate otherwise
   #
   # handlerTerminate is run when the interrupt/exception is unhandled by the
   # student handler, terminating the program and providing debugging messages.
   #------------------------------------------------------------------------------
   handler:
   #--------------------
   #   STUDENT HANDLER
   #--------------------
   # swap uscratch and a0
   csrrw a0, 0x040, a0 # a0 <- Addr[kernal stack], uscratch <- USERa0
   # save registers used in the handler except a0
   sw t0, 0(a0)   # Save t0
   sw t1, 4(a0)   # Save t1
   sw t2, 8(a0)   # Save t2
   # store USERa0
   csrr   t0, 0x040  # t0 <- USERa0
   sw     t0, 12(a0) # save USERa0
   li 	 t1, 0           # t1 <- 0
   csrrw  t0, 0x42, t1 	  # Move cause to t0 and clear it
   li     t1, 0x80000000  # t1 <- 0x80000000
   and    t2, t1, t0      # Get the 32th bit 
   beq    t2, zero, exit  # If the 32th bit is zero then we have an exception, branch to exit
   li 	 t1, 0x7FFFFFFF  # t1 <- 0x7FFFFFFF
   and 	 t0, t0, t1   	  # Extract exception code field
   li     t1, 4           # t1 <- 4
   beq    t0, t1, timerError  #  If exception code is 4 then we have a timer error, branch to timerError label
   j	    exit   	#  Else the interrupt does not have code 4, jump to exit

   # The exception code is 4 meaning we have an interrupt, update the stopwatch stored in seconds, restore the registers
   # and return
   timerError:
      lw    t0, seconds # t0 <- seconds
      addi  t1, t0, 1   # seconds + 1
      la    t0, seconds # t0 <- Addr[seconds]
      sw    t1, 0(t0)   # Addr[seconds] <- seconds
      #<Timer block of code>
      # load USERa0
      lw   t0, 12(a0) # t0 <- USERa0 
      csrw t0, 0x040  # uscratch <- usera0
      # load registers used in the handler except a0
      lw t0, 0(a0) # Restore t0
      lw t1, 4(a0) # Restore t1
      lw t2, 8(a0) # Restore t2
      # swap uscratch and a0
      csrrw a0, 0x040, a0  # a0 <- USERa0, uscratch <- Addr[kernal stack]
      uret # Return to EPC 

   # The exception code to not the timer interrupt, restore the registers and jump to handler terminate
   exit:
      # load USERa0
      lw   t0, 12(a0) # t0 <- USERa0 
      csrw t0, 0x040  # uscratch <- usera0
      # load registers used in the handler except a0
      lw t0, 0(a0) # Restore t0
      lw t1, 4(a0) # Restore t1
      lw t2, 8(a0) # Restore t2
      # swap uscratch and a0
      csrrw a0, 0x040, a0  # a0 <- USERa0, uscratch <- Addr[kernal stack]
      j   handlerTerminate # Jump to handlerTerminate
   
   #  Terminate program if the interrupt/exception is unhandled
   handlerTerminate:
   #  Print error msg before terminating
   li a7, 4
   la a0, INTERRUPT_ERROR
   ecall
   li a7, 34
   csrrci a0, 66, 0
   ecall
   li a7, 4
   la a0, INSTRUCTION_ERROR
   ecall
   li a7, 34
   csrrci a0, 65, 0
   ecall
   # Quit execution
   handlerQuit:
   li a7, 10
   ecall # End of program