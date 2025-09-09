.text
#-------------------------------------------------------------------------------
# UpdateY
#   Sets each Y[j] equal to Y[j] + X[col[j]] for j < A[i+1] where i is a global integer variable
# Arguments:
#       a0:  int *A
#	    a1:  int *X
#       a2:  int *Y
#       a3:  int *col
# Return Values:
#       None
# Register Usage:
#       t0: Stores the value j
#       t1: Stores the address of each of the pointers
#       t2: Stores the value of Y[j] 
#       t3: Stores the value of col[j] and its address
#       t4: Stores the value of Y[j] + X[col[j]]
#       t5: Stores the value of A[i + 1]
#       t6: Stores the address of Y[j]
#       s0: Stores the global integer variable i
#-------------------------------------------------------------------------------
UpdateY:
    slli    t1, s0, 2     # t1 <- i * 4
    add     t1, t1, a0    # t1 <- Addr(A[i])
    lw      t0, 0(t1)     # j = A[i]
    addi    s0, s0, 1     # i + 1
    slli    t1, s0, 2     # t1 <- i * 4
    add     t1, t1, a0    # t1 <- Addr(A[i + 1])
    lw      t5, 0(t1)     # t2 <- A[i + 1]
    bge     t0, t5, exit  # If j >= A[i+1] then dont enter the loop, go to exit label
    # Set Y[j] =  Y[j] + X[col[j]] for j < A[i + 1]
    updateLoop:
        slli    t1, t0, 2  # t1 <- j * 4
        add     t6, t1, a2 # t6 <- Addr(Y[j])
        lw      t2, 0(t6)  # t2 <- Y[j]
        add     t3, t1, a3 # t3 <- Addr(col[j])
        lw      t3, 0(t3)  # t3 <- col[j]
        slli    t3, t3, 2  # t3 <- col[j] * 4
        add     t3, t3, a1 # t3 <- Addr(X[col[j]])
        lw      t4, 0(t3)  # t4 <- X[col[j]]
        add     t4, t2, t4 # t4 <- Y[j] + X[col[j]]
        sw      t4, 0(t6)  # Y[j] <- Y[j] + X[col[j]]
        addi    t0, t0, 1  # j <- j + 1
        blt     t0, t5, updateLoop # If j < A[i+1] continue the loop 
        # Exit the program
        exit:
            jalr    zero, ra, 0  # Return to caller





    