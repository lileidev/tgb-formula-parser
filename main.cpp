#include "parser.h"
#include "lexer.h"

int extern yyparse();
int extern printMap();
extern void clearParserMap();

int main() {
    YY_BUFFER_STATE buffer = yy_scan_string("out: a - Floor(a / b) * b");
    yyparse();
    printMap();

    clearParserMap();

    yy_delete_buffer(buffer);

    buffer = yy_scan_string("out: a - Floor(a / b) * b");
    yyparse();
    printMap();

    clearParserMap();

    yy_delete_buffer(buffer);

    return 0;
}