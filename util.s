@ tabstop=4

	.arch armv6

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.section .text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.align	2

@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.global	ACGI_is_uint
	.type	ACGI_is_uint, %function
@--------------------------------------------------------------------------
@ ACGI_is_uint(const char *str);
@
@ @Desc:	Scan str and test if each byte is an ascii number character.
@
@ @str:		String to test.
@ @Return:	Pointer to @str terminator if @str consists entirely of digits;
@			NULL otherwise - including zero-length @str.
@--------------------------------------------------------------------------

ACGI_is_uint:

	@----------------------
	@ test @str isn't NULL pointer or zero-length
	@----------------------
	tst		r0, r0			@ check for null pointer
	ldrneb	r1,	[r0], #1	@ load byte and increase pointer
	tstne	r1, r1			@ end of string?
	beq		4f				@NAN if true
	@----------------------

	@----------------------
	@ while (isnum(*@str)) ++@str;
	@----------------------
	b		2f				@LOOP
1: @CONTINUE
	ldrb	r1,	[r0], #1	@ load byte and increase pointer
2: @LOOP
	cmp		r1, #'0
	blt		3f				@BREAK if less than '0'
	cmp		r1, #'9
	ble		1b				@CONTINUE if '9' or less
	@----------------------

3: @BREAK
	tst		r1, r1			@ end of string?
	subeq	r0, #1			@ yes, return pointer to @str terminator
	bxeq	lr

4: @NAN
	eor		r0, r0			@ return NULL
	bx		lr
