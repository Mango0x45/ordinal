%{
#include <err.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define YY_USER_ACTION ECHO;

const char empty_field[] = "argument to the -p option contains an empty field";
const char invalid_char[] = "argument to the -p option must be a "
                            "comma-seperated list of positive integers";
const char final_comma[] = "argument to the -p option contains trailing comma";
const char empty_string[] = "argument to the -p option cannot be "
                            "the empty string";

const char *argv0;
size_t pos;
struct {
	size_t *ps, len;
} positions;

static void usage(void);
static void append_positions(char *s);
static size_t atozu(const char *);
static bool print_ordinal(void);
%}

%option nodefault noinput nounput 8bit

%%

[0-9]*(1[0-9]|[04-9]) { pos++; if (print_ordinal()) fputs("th", stdout); }
[0-9]*1               { pos++; if (print_ordinal()) fputs("st", stdout); }
[0-9]*2               { pos++; if (print_ordinal()) fputs("nd", stdout); }
[0-9]*3               { pos++; if (print_ordinal()) fputs("rd", stdout); }

\n { pos = 0; }
[^0-9\n]+ ;

%%

void
usage(void)
{
	fprintf(stderr, "Usage: %s [-p indicies ...] [file ...]\n", argv0);
	exit(EXIT_FAILURE);
}

int
main(int argc, char **argv)
{
	int opt, rv;
	struct option longopts[] = {
		{"positions", required_argument, NULL, 'p'},
		{ NULL,       0,                 NULL,  0 }
	};

	argv0 = argv[0];
	rv = EXIT_SUCCESS;

	while ((opt = getopt_long(argc, argv, "p:", longopts, NULL)) != -1) {
		switch (opt) {
		case 'p':
			append_positions(optarg);
			break;
		default:
			usage();
		}
	}

	argc -= optind;
	argv += optind;

	if (argc == 0)
		yylex();
	for (int i = 0; i < argc; i++) {
		if (strcmp(argv[i], "-") == 0)
			yyin = stdin;
		else if ((yyin = fopen(argv[i], "r")) == NULL) {
			warn("fopen: %s", argv[i]);
			rv = EXIT_FAILURE;
			continue;
		}
		yylex();
		if (yyin != stdin)
			fclose(yyin);
	}

	return rv;
}

void
append_positions(char *raw)
{
	bool comma = true;
	const char *s;

	if (positions.ps != NULL) {
		warnx("the -p option should only be provided once");
		usage();
	}

	if (*raw == '\0') {
		warnx(empty_string);
		usage();
	}

	for (s = raw, positions.len++; *s; s++) {
		switch (*s) {
		case ',':
			if (comma)
				errx(EXIT_FAILURE, empty_field);
			comma = true;
			positions.len++;
			break;
		case '0': case '1': case '2': case '3': case '4':
		case '5': case '6': case '7': case '8': case '9':
			comma = false;
			break;
		default:
			errx(EXIT_FAILURE, invalid_char);
		}
	}

	if (comma == true)
		errx(EXIT_FAILURE, final_comma);

	if ((positions.ps = malloc(sizeof(size_t *) * positions.len)) == NULL)
		err(EXIT_FAILURE, "malloc");

	/* Iterate over each position, parse it, and sort the results.  It’s
	   safe to use strtok() and atozu() here since the input string has been
	   pre-validated. */
	s = strtok(raw, ",");
	for (size_t i = 0; s != NULL; i++) {
		positions.ps[i] = atozu(s);
		s = strtok(NULL, ",");
	}
}

size_t
atozu(const char *s)
{
	size_t n = 0;
	for (; *s; s++)
		n = n * 10 + *s - '0';
	return n;
}

bool
print_ordinal(void)
{
	if (positions.ps == NULL)
		return true;

	for (size_t i = 0; i < positions.len; i++) {
		if (positions.ps[i] == pos)
			return true;
	}
	return false;
}
