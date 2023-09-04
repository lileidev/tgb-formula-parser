# remove old files
rm parser.tab.h parser.tab.c lex.yy.c parser

# generate source code
flex lexer.l
bison -d parser.y -v

mv lex.yy.c lex.yy.h

g++ main.cpp parser.tab.c -o parser -ggdb
