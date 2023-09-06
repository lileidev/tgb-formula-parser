%option noyywrap
%option yylineno
%option outfile="lexer.c" header-file="lexer.h"

%{
#include <iostream>
#include <string.h>
#include "parser.h"

using namespace std;

extern int yylex();
%}

%%
[ \t\n]         ; // ignore space, tab and newline symbol
pi              { yylval.strval = strdup(yytext); return PI; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
[-+*/%@^(){},:]      { return yytext[0]; }
-?[0-9]+(\.[0-9]+)?         { yylval.strval = strdup(yytext); return NUMBER; }
.               { printf("Invalid character: %s\n", yytext); }
%%
