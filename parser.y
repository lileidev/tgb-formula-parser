%{
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
int count = 1000;

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

void clearParserMap() {
  parser_map.clear();
  count = 1000;
}

StringMap getParsedMap() {
  return parser_map;
}

%}

%union {
  char* strval;
}

%right ':'
%left '+' '-'
%left '*' '/' '%'
%left '@'
%left '^'
%nonassoc UMINUS

%define parse.error verbose

%token <strval> IDENTIFIER
%token <strval> NUMBER
%token <strval> PI
%type <strval> expr
%type <strval> expr_list
%type <strval> statement

%destructor { free($$); } expr

%start statement

%%

statement: IDENTIFIER ':' expr
  {
    atLine(__LINE__);
    auto it = parser_map.find($3);
    if (it != parser_map.end()) {
      parser_map[$1] = it->second;
      parser_map.erase($3);
    } else {
      addEntry($1, $3, __LINE__);
    }
    count += parser_map.size();
    $$ = $1;
  }
  ;

expr:
  '{' expr_list '}'
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
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
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
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
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Add", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | expr '-' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Subtract", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | '-' expr %prec UMINUS
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Neg", __LINE__);
    addEntry(tempIndex, $2, __LINE__);
    $$ = tempIndex;
  }
  | expr '*' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Multiply", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | expr '/' expr
  { 
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Divide", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | expr '%' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Remainder", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | expr '@' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "MatMul", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  } 
  | expr '^' expr
  { 
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    ;
    char* tempIndex = strcat(temp, index);
    addEntry(tempIndex, "Power", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);
    $$ = tempIndex;
  }
  | PI {
    atLine(__LINE__);
    char *temp = strdup("3.14159265358979323846264338327950288419716939937510");
    $$ = temp;
  }
  | IDENTIFIER
  {
    atLine(__LINE__);
    $$ = $1;
  }
  | NUMBER
  {
    atLine(__LINE__);
    $$ = $1;
  }
  ;

expr_list:
  expr
  {
    atLine(__LINE__);
    StringVector vec;
    pushStack(vec, __LINE__);
    addOperand($1, __LINE__);
    $$ = $1;
  }
  | expr_list ',' expr
  {
    atLine(__LINE__);
    addOperand($3, __LINE__);
    $$ = $1;
  }
  ;

%%

void yyerror(const char* s) {
  throw std::runtime_error(s);
}
