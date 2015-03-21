build_dir=./build/
objs=$(build_dir)main.o $(build_dir)urldecode.o $(build_dir)urlencode.o \
	 $(build_dir)util.o

all: $(objs)
	cc -o $(build_dir)exe $(objs)

$(build_dir)main.o: main.c
	cc -c -O2 -o $(build_dir)main.o main.c

$(build_dir)urldecode.o: urldecode.s
	cc -c -o $(build_dir)urldecode.o urldecode.s

$(build_dir)urlencode.o: urlencode.s
	cc -c -o $(build_dir)urlencode.o urlencode.s

$(build_dir)util.o: util.s
	cc -c -o $(build_dir)util.o util.s
