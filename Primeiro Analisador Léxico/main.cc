#include <stdio.h>
#include <string>

using namespace std;

enum TOKEN { _ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO, _FUNC };

extern "C" int yylex();  
extern "C" FILE *yyin;

void yyerror(const char* s);

#include "lex.yy.c"

auto p = &yyunput; // Para evitar uma warning de 'unused variable'

int main() {
  int token = 0;
  
  while( (token = yylex()) != 0 )  
    printf( "%d %s\n", token, yytext );
  
  return 0;
}
