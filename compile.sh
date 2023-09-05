# remove old files

rm lexer.c lexer.h parser.c parser.h


bison -d parser.y -o parser.c -v

flex lexer.l

g++ main.cpp lexer.c parser.c -o parser
