all: main.o urldecode.o urlencode.o
	cc -o exe main.o urldecode.o urlencode.o
	strip ./exe
	ls -l

main.o: main.c
	cc -c -O2 -o main.o main.c

urldecode.o: urldecode.s
	cc -c -o urldecode.o urldecode.s

urlencode.o: urlencode.s
	cc -c -o urlencode.o urlencode.s
