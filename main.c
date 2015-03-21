#define _GNU_SOURCE

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "acgi.h"

static void _test_ACGI_is_uint(void);
static void _test_ACGI_rtrim(void);
static void _test_ACGI_url(void);

int
main(int argc, char *argv[])
{
	_test_ACGI_is_uint();
	_test_ACGI_rtrim();
	_test_ACGI_url();

	puts("Tests passed.");

	return 0;
}

/* ---------------------------------------------------------------------------
 * STATIC FUNCTIONS
 * ---------------------------------------------------------------------------
 */
static void _test_ACGI_is_uint(void)
{
	puts(__FUNCTION__);

	const char *valid = "0123456789";
	const char *invalid[] = { "",
		                      "+01234",
							  "-1234",
							  0,
							  "1234a" };
 	char buf[2] = { 0, 0 };
	int i;

	for (i = 0; i < 256; ++i)
	{
		*buf = i;
		if (i > ('0' - 1) && i < ('9' + 1))
			assert(ACGI_is_uint(buf) == &buf[1]);
		else
			assert(ACGI_is_uint(buf) == 0);
	}

	assert(ACGI_is_uint(valid) == strchr(valid, 0));

	for (i = 0; i < sizeof(invalid) / sizeof(char *); ++i)
		assert(ACGI_is_uint(invalid[i]) == 0);
}

static void
_test_ACGI_rtrim(void)
{
	puts(__FUNCTION__);

	char before[][10] =	{	"test1",
							"",
							" ",
							"test    ",
							"example\n",
							"line\r\n"		};
	char after[][10] = 	{ 	"test1",
							"",
							"",
							"test",
							"example",
							"line" 			};
	size_t	n = sizeof(before) / 10;

	char *res;
	while (n)
	{
		--n;
		res = ACGI_rtrim(before[n]);
		assert(! strcmp(res, after[n]));
	}
}

static void
_test_ACGI_url(void)
{
	puts(__FUNCTION__);

	const char *urlvalid = "%._-+0123456789"
	                       "abcdefghijklmnopqrstuvwxyz"
	                       "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	char str[256];
	char enc[sizeof(str) * 3];
	char dec[sizeof(enc)];

	int c;

	for (c = 0; c < 256; ++c)
		str[c] = (char) c + 1;
	str[c] = 0;

	assert(strlen(str) == 255);

	assert(ACGI_url_encode(str, enc));
	assert(strspn(enc, urlvalid) == strlen(enc));

	strcpy(dec, enc);
	assert(ACGI_url_decode(dec));
	assert(strcmp(enc, dec));
	assert(! strcmp(str, dec));
}


