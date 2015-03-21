@ tabstop=4

	.arch armv6

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.section .text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.align	2
	.global	ACGI_is_uint
	.type	ACGI_is_uint, %function
@--------------------------------------------------------------------------
@ char *ACGI_is_uint(const char *str);
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
1: @LOOP
	ldrb	r2, [r1], #1 	@ load byte and increment pointer
	tst		r2, r2			@ if not zero byte
	bne		1b				@LOOP

	@ post increment has left pointer one beyond terminator
	sub		r1, #2			@ now pointing to last character 
	@----------------------

	eor		r3, r3			@ set to zero for terminating
	b		3f				@ENTRY
	@----------------------
	@ while (! (ptr < string)) --ptr;
	@----------------------
2: @TRIM
	strb	r3, [r1, #1]	@ zero invalid character
3: @ENTRY
	cmp		r1, r0			@ end loop if pointer < string 
	blt		4f				@BREAK
	ldrb	r2, [r1], #-1	@ load byte from string and decrement pointer
	cmp		r2, #0x21		@ below 0x21 are space and control chars
	blt		2b				@TRIM
	cmp		r2, #127		@ is it DEL?
	beq		2b				@TRIM
	@ valid character found. fall through / @BREAK
	@----------------------

4:@BREAK
	bx		lr

