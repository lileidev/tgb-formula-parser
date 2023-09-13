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
[-+*/%@^(){}:,\[\]]      { return yytext[0]; }
pi              { return PI; }
".shape"        { return GET_SHAPE; }
".strides"      { return GET_STRIDES; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
-?[0-9]+(\.[0-9]+)?         { yylval.strval = strdup(yytext); return NUMBER; }
.               { printf("Invalid character: %s\n", yytext); }
%%

// release strdup memory

