#define _GNU_SOURCE

#include <envz.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

extern char *ascii_hex_val_table;

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

int
main(int argc, char *argv[])
{
	if (argc != 3)
		return 1;

	if (! strcmp(argv[1], "url"))
	{
		char *enc, *ret;
		unsigned int enc_size;
		char *dec = url_decode(argv[2]);

		assert(dec);

		enc_size = url_encode_mem(dec);
		enc = malloc(enc_size);

		assert(enc);

		ret = url_encode(dec, enc);

		assert(enc_size == strlen(enc) + 1);

		printf("decoded:[%s] encoded:[%s] enc_size:[%u]\n",
		       dec, enc, enc_size);
	}
	else if (! strcmp(argv[1], "query"))
	{
		char *qs = getenv("QUERY_STRING");
		printf("%s\n", qs_get_value(argv[2], qs));
	}

	return 0;
}



