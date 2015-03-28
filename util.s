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
@ char *ACGI_rtrim(char *str, char *end);
@
@ @Desc:	Remove trailing space and control characters from @str. Space
@			and control characters are 127 (DEL) and anything below 0x21.
@			Any matching bytes will be zeroed.
@
@ @str:		String to trim.
@ @end:		Pointer to terminating byte of @str. If NULL, it will be
@			searched for before trimming begins.
@ @Return:	@str
@--------------------------------------------------------------------------

ACGI_rtrim:

	teq		r0, #0			@ @str == NULL?
	bxeq	lr				@ return if NULL
	teq		r1, #0			@ pointer to end of @str?
	bne		1f @START		@ yes, skip finding end of @str

	@----------------------
	@ move to last string character - before terminator
	@----------------------
	mov		r1, r0			@ copy string pointer
0:@FIND_STR_END
	ldrb	r2, [r1], #1 	@ load byte and increment pointer
	cmp		r2, #0			@ if not zero byte
	bne		0b @FIND_STR_END

	@ post increment has left pointer one beyond terminator
	sub		r1, #2			@ now pointing to last character
	@----------------------

1:@START
	eor		r3, r3			@ set to zero for terminating
	b		3f				@ENTRY
	@----------------------
	@ while (! (ptr < string)) --ptr;
	@----------------------
2:@TRIM
	strb	r3, [r1, #1]	@ zero invalid character
3:@ENTRY
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



@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.align	2
	.global	ACGI_file_get_size
	.type	ACGI_file_get_size, %function
	.extern	stat
@--------------------------------------------------------------------------
@ unsigned int ACGI_file_get_size(const char *path);
@
@ @Desc:	Get size of file @path. Uses c library function 'stat'.
@
@ @path:	Path to file.
@ @Return:	Non-zero if successful.
@--------------------------------------------------------------------------

ACGI_file_get_size:

	@ return 0 if NULL pointer
	teq		r0, #0
	bxeq	lr

	@ enter
	stmfd	sp!, {lr}
	sub		sp, #92

	@--------------------------
	@ stat (path, &stats)
	@--------------------------
	mov		r1, sp				@ struct address into r1
	bl		stat
	teq		r0, #0				@ stat returns 0 if successful
	ldreq	r0, [sp, #44]		@ so load file size
	movne	r0, #0				@ otherwise, 0
	@--------------------------

	@ leave
	add		sp, #92
	ldmfd	sp!, {pc}



@--------------------------------------------------------------------------
@ FUNCTION
@--------------------------------------------------------------------------
	.align	2
	.global	ACGI_file_to_str
	.type	ACGI_file_to_str, %function
	.extern	malloc
	.extern open
@--------------------------------------------------------------------------
@ char * ACGI_file_to_str(const char *path, char *str);
@
@ @Desc:	Read entire file into memory and terminate with '\0'.
@
@ @path:	Path to file.
@ @str:		Pointer to store file contents. If NULL, will be allocated
@			using malloc.
@
@ @Return:	@str if successful. NULL otherwise.
@--------------------------------------------------------------------------

ACGI_file_to_str:

	@--------------------------
	@ local variables
	@--------------------------
	@ r4 = @str
	@ r5 = file size
	@ r6 = flag memory allocated
	@ r7 = @path and file descriptor
	@ r8 = bytes read
	@--------------------------

	stmfd	sp!, {r4-r8, lr}

	@--------------------------
	@ get @path file size
	@--------------------------
	mov		r4, r1 				@ copy @str to r4
	movs	r7, r0				@ copy @path to r7
	beq		2f @LEAVE			@ NULL path
	bl		ACGI_file_get_size
	movs	r5, r0				@ r5 <- file size
	beq		2f @LEAVE			@ get file size failed. return 0
	@--------------------------

	movne	r6, #0				@ r6 <- flag memory not allocated
	@--------------------------
	@ allocate memory if @str == NULL
	@--------------------------
	teq		r4, #0				@ is @str NULL?
	bne		1f @OPEN FILE		@ no, skip memory allocation
	add		r0, r5, #1			@ file size + 1
	bl		malloc
	movs	r4, r0				@ @str <- allocated memory
	beq		2f @LEAVE			@ NULL pointer (malloc failed), return.
	mov		r6, #1				@ flag memory allocated
	@--------------------------
	
1:@OPEN FILE:
	@--------------------------
	mov		r0, r7				@ r0 <- @path
	bl		open				@ open (@path, O_RDONLY) r1 already = 0
	cmn		r0, #1				@ returned -1 ?
	beq		3f @ERROR			@ yes, open failed
	@--------------------------

	@--------------------------
	@ read file data into @str
	@--------------------------
	mov		r7, r0				@ 1 = file desc. @path no longer needed
	mov		r1, r4				@ 2 = @str
	mov		r2, r5				@ 3 = bytes to read (file size)
	bl		read
	mov		r8, r0				@ r8 <- bytes read
	@--------------------------

	@--------------------------
	@ close file
	@--------------------------
	mov		r0, r7 				@ 1 = file desc
	bl		close
	@--------------------------

	teq		r8, r5				@ bytes read == file size ?
	bne		3f @ERROR			@ no

	@--------------------------
	@ terminate @str
	@--------------------------
	mov		r1, #0				@ load string terminator
	strb	r1, [r4, r5]		@ terminate @str
	@--------------------------

	mov		r0, r4 				@ return @str

2:@LEAVE:
	ldmfd	sp!, {r4-r8, pc}

3:@ERROR:
	teq		r6, #1				@ was memory allocated ?
	@--------------------------  
	@ free allocated memory
	@--------------------------  
	moveq	r0, r4				@ 1 = @str
	bleq	free
	@--------------------------  
	mov		r0, #0				@ return NULL
	b		2b @LEAVE

	

