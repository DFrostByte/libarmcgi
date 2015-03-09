#include <stdio.h>
#include <ctype.h>
#include <string.h>

int
main(void)
{
	int c;
	char byte;
	int bytes_per_line = 8;
	int i;

	for(c = 0, i = 1; c < 256; ++c, ++i)
	{
		byte = 0;

		if (i == 1)
			printf("\t.byte\t");

		if (isalnum(c) || strchr("-_.", c))
			byte = c;

		printf("0x%02X", byte);

		if (i == bytes_per_line)
		{
			putchar('\n');
			i = 0;
		}
		else
			printf(", ");
	}

	return 0;
}