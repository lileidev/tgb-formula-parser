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

// A container to store allocated memory pointer
std::vector<char*> allocated_ptr;

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
  // free allocated memory by molloc and strdup to prevent memory leak.
  for (const auto &ptr : allocated_ptr) {
    # ifdef debug
      std::cout << ptr << " freed." << std::endl;
    # endif
    free(ptr);
  }
  allocated_ptr.clear();
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
%left '.'
%nonassoc UMINUS

%define parse.error verbose

%token <strval> IDENTIFIER
%token <strval> NUMBER
%token <strval> GET_SHAPE
%token <strval> GET_STRIDES
%token <strval> PI

%type <strval> expr
%type <strval> expr_list
%type <strval> get_property


%start expr

%%

expr:
  get_property
  {
    atLine(__LINE__);
    $$ = $1;
  }
  | '{' expr_list '}'
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);

    addEntry(tempIndex, "vector", __LINE__);
    StringVector vec = parser_stack.top();
    for (auto &v: vec) {
      addEntry(tempIndex, v.c_str(), __LINE__);
    }

    popStack(__LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);

    $$ = tempIndex;
  }
  | IDENTIFIER '[' NUMBER ']'
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "RetrievingValueByIndex", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back($1);
    allocated_ptr.emplace_back($3);
    allocated_ptr.emplace_back(tempIndex);

    $$ = tempIndex;
  }
  | get_property '[' NUMBER ']'
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "RetrievingValueByIndex", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);    

    allocated_ptr.emplace_back($3);
    allocated_ptr.emplace_back(tempIndex);

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
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, $1, __LINE__);
    StringVector vec = parser_stack.top();
    for (auto &v: vec) {
      addEntry(tempIndex, v.c_str(), __LINE__);
    }

    popStack(__LINE__);
    if (!parser_stack.empty()) {
      addOperand(tempIndex, __LINE__);
    }

    free(temp);
    free(index);

    allocated_ptr.emplace_back($1);
    allocated_ptr.emplace_back(tempIndex);

    $$ = tempIndex;
  }
  | expr '+' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Add", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex); 

    $$ = tempIndex;
  }
  | expr '-' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Subtract", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);   

    $$ = tempIndex;
  }
  | '-' expr %prec UMINUS
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Neg", __LINE__);
    addEntry(tempIndex, $2, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex); 

    $$ = tempIndex;
  }
  | expr '*' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Multiply", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);  

    $$ = tempIndex;
  }
  | expr '/' expr
  { 
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Divide", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);    

    $$ = tempIndex;
  }
  | expr '%' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Remainder", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);   

    $$ = tempIndex;
  }
  | expr '@' expr
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "MatMul", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);    

    $$ = tempIndex;
  } 
  | expr '^' expr
  { 
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "Power", __LINE__);
    addEntry(tempIndex, $1, __LINE__);
    addEntry(tempIndex, $3, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back(tempIndex);

    $$ = tempIndex;
  }
  | PI {
    atLine(__LINE__);
    char *tempPi = strdup("3.14159265358979323846264338327950288419716939937510");

    allocated_ptr.emplace_back(tempPi);
  
    $$ = tempPi;
  }
  | IDENTIFIER
  {
    atLine(__LINE__);

    allocated_ptr.emplace_back($1);

    $$ = $1;
  }
  | NUMBER
  {
    atLine(__LINE__);

    allocated_ptr.emplace_back($1);

    $$ = $1;
  }
  | IDENTIFIER ':' expr
  {
    atLine(__LINE__);
    auto it = parser_map.find($3);
    if (it != parser_map.end()) {
      parser_map[$1] = it->second;
      parser_map.erase($3);
      atLine(__LINE__);
    } else {
      addEntry($1, $3, __LINE__);
    }
    count += parser_map.size();

    allocated_ptr.emplace_back($1);

    $$ = $1;
  }
  ;

get_property:
  IDENTIFIER GET_SHAPE
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "GetShapeOfTensor", __LINE__);
    addEntry(tempIndex, $1, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back($1);
    allocated_ptr.emplace_back(tempIndex);   

    $$ = tempIndex;
  }
  | IDENTIFIER GET_STRIDES
  {
    atLine(__LINE__);
    char* temp = strdup("t");
    char* index = strdup(std::to_string(parser_map.size()+count).c_str());
    size_t tempLength = strlen(temp);
    size_t indexLength = strlen(index);
    size_t maxLength = tempLength + indexLength + 1;  // add 1 for end symbol

    char* tempIndex = (char*)malloc(maxLength);
    strcpy(tempIndex, temp);
    strncat(tempIndex, index, maxLength - tempLength);
    addEntry(tempIndex, "GetStridesOfTensor", __LINE__);
    addEntry(tempIndex, $1, __LINE__);

    free(temp);
    free(index);

    allocated_ptr.emplace_back($1);
    allocated_ptr.emplace_back(tempIndex);   

    $$ = tempIndex;   
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
