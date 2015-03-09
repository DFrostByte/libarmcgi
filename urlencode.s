@ tabstop=4

	.arch armv6

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.section .text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.align	2

@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.global	url_encode
	.type	url_encode, %function
@--------------------------------------------------------------------------
@ char *url_encode(const char *str, char *url);
@
@ @Desc:	Replace ' ' with '+'. Characters that are not in the ranges
@			0-9, a-z, A-Z and not in ".-_" will be replaced with %XX, where
@			"XX" is two hex characters representing the character's value.
@
@			As escaped characters require three bytes, @url will not need to
@			be larger than (strlen(str) * 3).
@
@ @str:		String to be encoded.
@ @url:		Memory to store encoded string.
@ @Return:	@url or NULL (0) if either parameter is NULL.
@--------------------------------------------------------------------------
url_encode:
	@ test for NULL parameters
	tst		r0, r0
	tstne	r1,	r1
	eoreq	r0, r0
	bxeq	lr				@ return NULL pointer

	@ save url address for return and registers used during hex decoding
	push	{r1,r4-r6}

	ldr	    r5, =table_valid_url_characters
	ldr	    r6, =table_hex_characters

1: @LOOP
	ldrb	r2, [r0], #1	@ load str character and increment pointer
	tst		r2, r2			@ end of string?
	streqb	r2, [r1]		@ null-terminate @url
	beq		3f				@BREAK

	@---------------------
	@ replace ' ' with '+'
	@---------------------
	cmp		r2, #0x20
	moveq	r2, #'+
	beq		2f				@WRITE
	@---------------------

	@---------------------
	@ does character need encoding?
	@---------------------
	ldrb	r3, [r5, r2]	@ check validity in table_valid_url_characters
	cmp		r3, #0			@ will be 0 if needs encoding
	bne		2f				@WRITE

	@ escape character in r2
	and		r3, r2, #0x0F	@ get low nibble value
	mov		r4, r2, lsr #4	@ get high nibble value
	ldrb	r3, [r6, r3]	@ low nibble ascii hex character
	ldrb	r4, [r6, r4]	@ high nibble

	@ write 3-byte escape to @url
	mov		r2, r3, lsl #16	@ low nibble character
	orr		r2, r4, lsl #8	@ high nibble character
	orr		r2, #'%
	str		r2, [r1], #3	@ save to @url and point @url past new data

	b		1b				@LOOP
	@---------------------

2: @WRITE
	strb	r2, [r1], #1	@ save byte using the update pointer
	b		1b				@LOOP

3: @BREAK

	pop		{r0,r4-r6}		@ restore used registers and return @url
	bx		lr



@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.global	url_encode_mem
	.type	url_encode_mem, %function
@--------------------------------------------------------------------------
@ unsigned int url_encode_mem(const char *str);
@
@ @Desc:	Calculate how many bytes of memory would be needed to store
@			a url-encoded version of @str (including terminator).
@
@ @str:		String to be encoded.
@ @Return:	Number of bytes needed to store encoded @str.
@--------------------------------------------------------------------------
url_encode_mem:
	tst		r0, r0			@ null pointer?
	bxeq	lr				@ return 0

	ldr	    r3, =table_valid_url_characters

	eor		r1, r1			@ clear counter
1: @LOOP
	ldrb	r2, [r0], #1	@ read byte from @str and increment pointer
	add		r1, #1			@ increment counter

	tst		r2, r2			@ end of @str?
	beq		2f				@BREAK

	@ spaces are invalid but would be replaced with only one character
	teq		r2, #0x20
	beq		1b				@LOOP

	@ would this character need to be encoded?
	ldrb	r2, [r3, r2]	@ check validity in table_valid_url_characters
	tst		r2, r2			@ will be 0 if needs encoding
	addeq	r1, #2			@ needs another 2 bytes of space for hex

	b		1b				@LOOP

2: @BREAK

	mov		r0, r1			@ return count of bytes needed
	bx		lr




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.section .rodata
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.align	2

@--------------------------------------------------------------------------
@ VARIABLE
@--------------------------------------------------------------------------
	.global table_valid_url_characters
@--------------------------------------------------------------------------
@ const char table_valid_url_characters[256];
@
@ An ascii char value can be used as an index to test if a character should
@ be escaped when used in a url. All invalid characters have the value 0x00
@--------------------------------------------------------------------------
table_valid_url_characters:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x2D, 0x2E, 0x00
	.byte	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
	.byte	0x38, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47
	.byte	0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F
	.byte	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57
	.byte	0x58, 0x59, 0x5A, 0x00, 0x00, 0x00, 0x00, 0x5F
	.byte	0x00, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67
	.byte	0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F
	.byte	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77
	.byte	0x78, 0x79, 0x7A, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00



@--------------------------------------------------------------------------
@ VARIABLE
@--------------------------------------------------------------------------
	.global table_hex_characters
@--------------------------------------------------------------------------
@ const char * table_hex_characters = "0123456789ABCDEF";
@
@ This table can be used for looking up the character representation of a
@ nibble's value.
@--------------------------------------------------------------------------
table_hex_characters:
	.asciz	"0123456789ABCDEF"
