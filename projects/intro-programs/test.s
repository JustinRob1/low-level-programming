.text
main:
	li  s0, 0xFF0000FF
	li  s1, 0xABCD1234
	li  s2, 0x000FF000
	addi s3, zero, -1

	slli s3, s3, 8

	srli s3, s3, 16

	or   s3, s3, s2
	ecall
