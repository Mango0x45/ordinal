target = ordinal

CC = cc
LEX = flex
CFLAGS = \
	-Wall -Wextra -Wpedantic -Werror \
	-O3 -march=native -mtune=native -pipe
LDLIBS = -lfl

PREFIX = /usr/local
DPREFIX = ${DESTDIR}${PREFIX}

all: ${target}
${target}: lex.yy.c
	${CC} ${CFLAGS} ${LDLIBS} -o $@ $<

lex.yy.c: main.l
	${LEX} $<

install:
	mkdir -p ${DPREFIX}/bin ${DPREFIX}/share/man/man1
	cp ${target} ${DPREFIX}/bin
	cp ${target}.1 ${DPREFIX}/share/man/man1

clean:
	rm -f ${target} lex.yy.c
