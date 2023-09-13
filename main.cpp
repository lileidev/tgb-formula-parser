#include "parser.h"
#include "lexer.h"

int extern yyparse();
int extern printMap();
extern void clearParserMap();

int main() {
    YY_BUFFER_STATE buffer = yy_scan_string("ExpandWrapper(Arrange(t1), {t0, t1}) * stride[0]");
    yyparse();
    printMap();

    clearParserMap();

    return 0;
}