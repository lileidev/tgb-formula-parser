#include "parser.h"
#include "lexer.h"

int extern yyparse();
int extern printMap();
extern void clearParserMap();

int main() {
    YY_BUFFER_STATE buffer = yy_scan_string("t0: log((1+x)/(1-x))/2");
    yyparse();
    printMap();
    clearParserMap();
    buffer = yy_scan_string("t0: log((1+x)/(1-x))/2");
    yyparse();
    printMap();

    return 0;
}