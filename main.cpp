#include "parser.h"
#include "lexer.h"

int extern yyparse();
int extern printMap();
extern void clearParserMap();

int main() {
    YY_BUFFER_STATE buffer = yy_scan_string("t2: -1 + pi +  (-output.shape[1] / y * dout)");
    yyparse();
    printMap();

    return 0;
}