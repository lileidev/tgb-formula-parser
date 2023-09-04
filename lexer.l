%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
extern int yylex();
%}

%%
[ \t\n]         ; // ignore space, tab and newline symbol

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
[-+*/%@^(){}=|,]      { return yytext[0]; }
[0-9]+          { yylval.strval = strdup(yytext); return NUMBER; }
.               { printf("Invalid character: %s\n", yytext); }
%%
