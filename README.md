# ordinal

Ordinal is a command-line utility to convert cardinal numbers into ordinal ones.
It’s functionality can be summed up nicely in the two following examples:

```sh
$ seq 20 | ordinal
1st
2nd
3rd
4th
5th
6th
7th
8th
9th
10th
11th
12th
13th
14th
15th
16th
17th
18th
19th
20th
```

```sh
$ date +'%-d of %B, %Y' | ordinal -p1
4th of October, 2023
```

For more details, read the `ordinal(1)` manual page.

## Installation

Installation is very simple:

```sh
$ make
$ sudo make install
```

If you do not have `flex` installed, you probably have `lex` instead so you can
try the following:

```sh
$ make LEX=lex LFLAGS= LDLIBS=-ll
```

If the above doesn’t work, send an email over to
`~mango/public-inbox@lists.sr.ht` describing your problem.
