%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
#include <vector>
#include <stack>
#include <iostream>

// #define debug

extern int yylex();
extern void yyerror(const char*);

typedef std::vector<std::string> StringVector;
typedef std::map<std::string, StringVector> StringMap;
typedef std::stack<StringVector> StringStack;

StringMap parser_map;
StringStack parser_stack;

void addEntry(const char* key, const char* value, int lineno) {
    #ifdef debug
      std::cout << "add map at " << lineno << ": " << value << std::endl;
    #endif
    parser_map[key].push_back(value);
}

void addOperand(const char* operand, int lineno) {
    #ifdef debug
      std::cout << "add operands at " << lineno << ": " << operand << std::endl;
    #endif
    parser_stack.top().push_back(operand);
}

void pushStack(std::vector<std::string> vec, int lineno) {
    #ifdef debug  
        std::cout << "push stack at " << lineno << std::endl;
    #endif
    parser_stack.push(vec);
}

void popStack(int lineno) {
    #ifdef debug  
        std::cout << "pop stack at " << lineno << std::endl;
    #endif
    parser_stack.pop();
}

void atLine(int lineno) {
  #ifdef debug
    std::cout << "matched line: " << lineno << std::endl;
  #endif
}

void printMap() {
    for (const auto& entry : parser_map) {
        printf("{ \"%s\": ", entry.first.c_str());
        const StringVector& values = entry.second;
        printf("%s", values[0].c_str());
        for (size_t i = 1; i < values.size(); ++i) {
            printf(", %s", values[i].c_str());
        }
        printf(" }\n");
    }
}

%}

%union {
    char* strval;
}

%left '+' '-'
%left '*' '/' '%'
%left '@'
%left '^'
%nonassoc UMINUS

%token <strval> IDENTIFIER
%token <strval> NUMBER

%type <strval> statement
%type <strval> expr
%type <strval> expr_list


%start statement

%%


statement:
  IDENTIFIER '=' expr
  {
      atLine(__LINE__);
      addEntry($1, $3, __LINE__);
      $$ = $1;
  }
  | expr
  {
    atLine(__LINE__);
    $$ = $1
  }

expr:
    IDENTIFIER
    {
        atLine(__LINE__);
        $$ = $1;
    }
    | NUMBER
    {
        atLine(__LINE__);
        $$ = $1;
    }
    | '{' expr_list '}'
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "vector", __LINE__);
        StringVector vec = parser_stack.top();
        for (auto &v: vec) {
          addEntry(tempIndex, v.c_str(), __LINE__);
        }

        popStack(__LINE__);
        
        $$ = tempIndex;
    }
    | '(' expr_list ')'
    {
        atLine(__LINE__);
        $$ = $2;
    }
    | IDENTIFIER '(' expr_list ')'
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, $1, __LINE__);
        StringVector vec = parser_stack.top();
        for (auto &v: vec) {
          addEntry(tempIndex, v.c_str(), __LINE__);
        }

        popStack(__LINE__);
        if (!parser_stack.empty()) {
          addOperand(tempIndex, __LINE__);
        }

        $$ = tempIndex;
    }
    | expr '+' expr
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "add", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    | expr '-' expr
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "subtract", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    | '-' expr %prec UMINUS
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "neg", __LINE__);
        addEntry(tempIndex, $2, __LINE__);
        $$ = tempIndex;
    }
    | expr '*' expr
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "multiply", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    | expr '/' expr
    { 
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "divide", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    | expr '%' expr
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "remainder", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    | expr '@' expr
    {
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "matmul", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    } 
    | expr '^' expr
    { 
        atLine(__LINE__);
        char* temp = strdup("t");
        char* index = strdup(std::to_string(parser_map.size()).c_str());
        char* tempIndex = strcat(temp, index);
        addEntry(tempIndex, "power", __LINE__);
        addEntry(tempIndex, $1, __LINE__);
        addEntry(tempIndex, $3, __LINE__);
        $$ = tempIndex;
    }
    ;

expr_list:
    expr_list ',' expr
    {
        atLine(__LINE__);
        addOperand($3, __LINE__);
        $$ = $1;
    }
    | expr
    {
        atLine(__LINE__);
        StringVector vec;
        pushStack(vec, __LINE__);
        addOperand($1, __LINE__);
        $$ = $1;
    }
    ;

%%

void yyerror(const char* s) {
    printf("Error: %s\n", s);
}
