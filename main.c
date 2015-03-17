#define _GNU_SOURCE

#include <envz.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

extern char *ascii_hex_val_table;

extern char *
ACGI_is_uint(const char *str);

extern char *
url_decode(char *url);

extern char *
url_encode(char *str, char *url);
extern unsigned int
url_encode_mem(char *str);


char *
qs_get_value(const char *key, const char *query_str)
{
	char *qs = strdupa(query_str);
	const size_t qs_size = strlen(qs) + 1;
	char *ptr = NULL;
	char *found = NULL;

	if (! key || ! *key || ! qs)
		return NULL;

	/* prepare query string for use with envz */
	for (ptr = qs; ptr = strchr(ptr, '&'); ++ptr)
		*ptr = '\0';

	return strdup(envz_get(qs, qs_size, key));
}

static char *
_url_decode(char *str)
{
	char *ptr   =  str;
	char *write =  str;
	char  val   = *str;
	char hex[2];

	for ( ; val; ++ptr, ++write)
	{
		val = *ptr;

		if (val == '+')
			val = ' ';
		else if (val == '%')
		{
			/* check first expected hex character isn't null to avoid reading
			 * second hex character from beyond the string
			 */
			if (ptr[1])
			{
				hex[0] = ascii_hex_val_table[ptr[1]];
				hex[1] = ascii_hex_val_table[ptr[2]];

				if (hex[0] != 0xFF && hex[1] != 0xFF)
				{
					val = (hex[0] << 4) | hex[1];
					ptr += 2;
				}
			}
		}

		*write = val;
	}

	return str;
}

static void _test_ACGI_is_uint(void)
{
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

int
main(int argc, char *argv[])
{
	_test_ACGI_is_uint();

	puts("Tests passed.");

	return 0;
}



