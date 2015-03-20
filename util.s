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



@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.align	2
	.global	ACGI_rtrim
	.type	ACGI_rtrim, %function
@--------------------------------------------------------------------------
@ char *ACGI_rtrim(char *str);
@
@ @Desc:	Remove trailing space and control characters from @str. Space
@			and control characters are 127 (DEL) and anything below 0x21.
@			Any matching bytes will be zeroed.
@
@ @str:		String to trim.
@ @Return:	@str
@--------------------------------------------------------------------------

ACGI_rtrim:

	movs	r1, r0			@ copy string pointer
	bxeq	lr				@ return if NULL

	@----------------------
	@ move to last string character - before terminator
	@----------------------
.L_rtrim_get_last_char:
	ldrb	r2, [r1], #1
	tst		r2, r2			@ zero byte?
	bne		.L_rtrim_get_last_char

	@ post increment has left pointer one beyond terminator
	sub		r1, #2			@ now pointing to last character 
	@----------------------

	eor		r3, r3			@ set to zero for terminating
	b		.L_rtrim_loop		
	@----------------------
	@ while (! (ptr < string)) --ptr;
	@----------------------
.L_rtrim_invalid: 
	strb	r3, [r1, #1]	@ zero invalid character
.L_rtrim_loop:
	cmp		r1, r0
	blt		.L_rtrim_end	@ pointing before first string char
	ldrb	r2, [r1], #-1	@ load byte from string
	cmp		r2, #0x21		@ below 0x21 are space and control chars
	blt		.L_rtrim_invalid
	cmp		r2, #127		@ is it DEL?
	beq		.L_rtrim_invalid
	@ valid character found
	@----------------------

.L_rtrim_end:
	bx		lr

