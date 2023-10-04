target = ordinal

CC = cc
LEX = flex
CFLAGS = \
	-Wall -Wextra -Wpedantic -Werror \
	-O3 -march=native -mtune=native -pipe
LDLIBS = -lfl

all: ${target}
${target}: lex.yy.c
	${CC} ${CFLAGS} ${LDLIBS} -o $@ $<

lex.yy.c: main.l
	${LEX} $<

clean:
	rm -f ${target} lex.yy.c
