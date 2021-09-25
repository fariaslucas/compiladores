%{
#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <map>

using namespace std;

struct Atributos {
  vector<string> c;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror( const char* );

vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, string b );

string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
void imprime( vector<string> codigo );
vector<string> vazio;

void declara_var( vector<string> var, int linha );
void checa_declaracao( vector<string> var );
map<vector<string>, int> vars;
int linha = 1;

%}

// Tokens
%token ID NUM STR LET IF ELSE WHILE FOR

// Start
%start S

// Associatividade e precedência
%right '=' 
%nonassoc '<' '>' IGUAL
%left '+' '-'
%left '*' '/' '%'

%%

S : CMDs  { imprime( resolve_enderecos( $1.c ) ); }
  ;

CMDs : CMD ';' CMDs { $$.c = $1.c + $3.c; }
     | CMDEST CMDs  { $$.c = $1.c + $2.c; }
     |              { $$.c = vazio; }
     ;

CMD : ATR           { $$.c = $1.c + "^"; }
    | LET DECLVARs  { $$ = $2; }
    ;

CMDEST : IF '(' E ')' BODY ELSEs            { string then = gera_label( "then" );
                                              string endif = gera_label( "end_if" );
                                              $$.c = $3.c + then + "?" + $6.c + endif + "#" + (":" + then) + $5.c + (":" + endif); }
       | WHILE '(' E ')' BODY               { string then = gera_label( "then" );
                                              string endwhile = gera_label( "end_while" );
                                              $$.c = vazio + (":" + then) + $3.c + "!" + endwhile + "?" + $5.c + then + "#" + (":" + endwhile); }
       | FOR '(' CMD ';' E ';' ATR ')' BODY { string then = gera_label( "then" );
                                              string endfor = gera_label( "end_for" );
                                              $$.c = $3.c + (":" + then) + $5.c + "!" + endfor + "?" + $9.c + $7.c + "^" + then + "#" + (":" + endfor); } 
       ;

ATR : ID '=' ATR      { checa_declaracao( $1.c ); $$.c = $1.c + $3.c + "="; }
    | IDPROP '=' ATR  { $$.c = $1.c + $3.c + "[=]"; }
    | E
    ;

DECLVARs : DECLVAR ',' DECLVARs { $$.c = $1.c + $3.c; }
         | DECLVAR
         ;

DECLVAR : ID '=' E { declara_var( $1.c, linha ); 
                     $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^"; }
        | ID       { declara_var( $1.c, linha);
                     $$.c = $1.c + "&"; }
        ;

ELSEs : ELSE BODY { $$ = $2; }
      |           { $$.c = vazio; }
      ;

BODY : CMD ';'      { $$.c + $1.c; }
     | '{' CMDs '}' { $$ = $2; }
     | CMDEST
     ;

IDPROP : E '[' E ']' { $$.c = $1.c + $3.c; }
       | E '.' ID    { $$.c = $1.c + $3.c; }

E : ID '=' E      { $$.c = $1.c + $3.c + "="; }
  | IDPROP '=' E  { $$.c = $1.c + $3.c + "[=]"; }
  | E '<' E       { $$.c = $1.c + $3.c + "<"; }
  | E '>' E       { $$.c = $1.c + $3.c + ">"; }
  | E IGUAL E     { $$.c = $1.c + $3.c + "=="; }
  | E '+' E       { $$.c = $1.c + $3.c + "+"; }
  | E '-' E       { $$.c = $1.c + $3.c + "-"; }
  | E '*' E       { $$.c = $1.c + $3.c + "*"; }
  | E '/' E       { $$.c = $1.c + $3.c + "/"; }
  | F
  ;

F : ID        { checa_declaracao( $1.c ); $$.c = $1.c + "@"; }
  | IDPROP    { $$.c = $1.c + "[@]"; }
  | NUM       { $$.c = $1.c; }
  | '-' NUM   { $$.c = vazio + "0" + $2.c + "-"; }
  | STR       { $$.c = $1.c; }
  | '(' E ')' { $$ = $2; }
  | '{' '}'   { $$.c = vazio + "{}"; }
  | '[' ']'   { $$.c = vazio + "[]"; }

%%

#include "lex.yy.c"

void yyerror( const char* st) {
  puts( st );
  printf( "Proximo a: %s\n", yytext );
  exit( 1 );
}

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+( vector<string> a, string b ) {
  a.push_back( b );
  return a;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
      label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

void imprime( vector<string> codigo ) {
  for( int i = 0; i < codigo.size(); i++ ) {
    cout << codigo[i] << endl;
  }

  cout << "." << endl;
}

void declara_var( vector<string> var, int linha ) {
  auto elemento = vars.find( var );
  if( elemento != vars.end() ) {
    printf("Erro: a variável '%s' já foi declarada na linha %d.\n", var.back().c_str(), elemento->second);
    exit( 1 );
  }

  vars[var] = linha;
}

void checa_declaracao( vector<string> var ) {
  auto elemento = vars.find( var );
  if( elemento == vars.end() ) {
    printf("Erro: a variável '%s' não foi declarada.\n", var.back().c_str());
    exit( 1 );
  }
}

int main( int argc, char* argv[] ) {
  yyparse();

  return 0;
}