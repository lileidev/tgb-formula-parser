#include "parser.tab.h"
#include "lex.yy.h"

int extern yyparse();
int extern printMap();

int main() {
    // YY_BUFFER_STATE buffer = yy_scan_string("a + b + reducemean(x, {1, 2, 3})");
    yyparse();
    printMap();
    return 0;
}