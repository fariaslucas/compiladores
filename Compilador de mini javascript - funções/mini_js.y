%{
#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <map>
#include <algorithm>

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
int coluna = 1;

vector<string> funcs;
int count_args = 0;
vector<string> conserta_argumentos( vector<string> pilha );

string trim( string str_inicial, string remover );
vector<string> tokeniza( string str );

%}

// Tokens
%token ID NUM STR 
%token LET IF ELSE WHILE FOR FUNCTION RETURN ASM
%token IG DIF MAIG MEIG SETA

// Start
%start S

// Associatividade e precedência
%right '=' 
%left SETA
%nonassoc '<' '>' IG DIF MAIG MEIG
%left '+' '-'
%left '*' '/' '%'

%%

S : CMDs  { $$.c = $1.c + "." + funcs; imprime( resolve_enderecos( $$.c ) ); }
  ;

CMDs : CMD ';' CMDs   { $$.c = $1.c + $3.c; }
     | CMDEST CMDs    { $$.c = $1.c + $2.c; }
     | FUNC CMDs      { $$.c = $1.c + $2.c; }
     |                { $$.c = vazio; }
     ;

CMD : E             { $$.c = $1.c + "^"; }
    | LET DECLVARs  { $$.c = $2.c; }
    | RETURN E      { $$.c = $2.c + "'&retorno'" + "@"+ "~"; }
    | E ASM         { $$.c = $1.c + $2.c + "^"; }
    ;

DECLVARs : DECLVAR ',' DECLVARs { $$.c = $1.c + $3.c; }
         | DECLVAR
         ;

DECLVAR : ID '=' E { declara_var( $1.c, linha ); $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^"; }
        | ID       { declara_var( $1.c, linha ); $$.c = $1.c + "&"; }
        ;

CMDEST : IF '(' E ')' BODY ELSEs            { string then = gera_label( "then" );
                                              string endif = gera_label( "end_if" );
                                              $$.c = $3.c + then + "?" + $6.c + endif + "#" + (":" + then) + $5.c + (":" + endif); }
       | WHILE '(' E ')' BODY               { string then = gera_label( "then" );
                                              string endwhile = gera_label( "end_while" );
                                              $$.c = vazio + (":" + then) + $3.c + "!" + endwhile + "?" + $5.c + then + "#" + (":" + endwhile); }
       | FOR '(' CMD ';' E ';' E ')' BODY   { string then = gera_label( "then" );
                                              string endfor = gera_label( "end_for" );
                                              $$.c = $3.c + (":" + then) + $5.c + "!" + endfor + "?" + $9.c + $7.c + "^" + then + "#" + (":" + endfor); } 
       ;

ELSEs : ELSE BODY { $$.c = $2.c; }
      |           { $$.c = vazio; }
      ;

BODY : CMD ';'      { $$.c = $1.c; }
     | '{' CMDs '}' { $$.c = $2.c; }
     ;

IDPROP : E '[' E ']' { $$.c = $1.c + $3.c; }
       | E '.' ID    { $$.c = $1.c + $3.c; }
       ;

FUNC : FUNCTION ID '(' ARGs ')' BODY { string function = gera_label( "function" ); 
                                       $$.c = $2.c + "&" + $2.c + "{}" + "=" + "'&funcao'" + function + "[=]" + "^";
                                       $4.c = conserta_argumentos( $4.c );
                                       funcs = funcs + (":" + function) + $4.c + $6.c + "undefined" + "@" + "'&retorno'" + "@" + "~"; }
     ;

ARGs : ID           { count_args++; $$.c = $1.c + "&" + $1.c + "arguments" + "@" + "indice" + "[@]" + "=" + "^"; }            
     | ID ',' ARGs  { count_args++; $$.c = $1.c + "&" + $1.c + "arguments" + "@" + "indice" + "[@]" + "=" + "^" + $3.c; }
     |              { $$.c = vazio; }
     ;

CALLFUNC : ID '(' CALLARGS ')'     { $$.c = $3.c + to_string(count_args) + $1.c + "@" + "$"; }
         | IDPROP '(' CALLARGS ')' { $$.c = vazio + to_string(count_args) + $1.c +  "[@]" + "$"; }
         ;

CALLARGS : E         
         | E ',' CALLARGS  { $$.c = $1.c + $3.c; }
         |                 { $$.c = vazio; }
         ;

E : ID '=' E      { checa_declaracao( $1.c ); $$.c = $1.c + $3.c + "="; }
  | IDPROP '=' E  { $$.c = $1.c + $3.c + "[=]"; }
  | E SETA E      { $$.c = $1.c + $3.c + "=>"; }
  | E '<' E       { $$.c = $1.c + $3.c + "<"; }
  | E '>' E       { $$.c = $1.c + $3.c + ">"; }
  | E IG E        { $$.c = $1.c + $3.c + "=="; }
  | E DIF E       { $$.c = $1.c + $3.c + "!="; }
  | E MAIG E      { $$.c = $1.c + $3.c + ">="; }
  | E MEIG E      { $$.c = $1.c + $3.c + "<="; }
  | E '+' E       { $$.c = $1.c + $3.c + "+"; }
  | E '-' E       { $$.c = $1.c + $3.c + "-"; }
  | E '*' E       { $$.c = $1.c + $3.c + "*"; }
  | E '/' E       { $$.c = $1.c + $3.c + "/"; }
  | E '%' E       { $$.c = $1.c + $3.c + "%"; }
  | F
  ;

F : ID        { $$.c = $1.c + "@"; }
  | IDPROP    { $$.c = $1.c + "[@]"; }
  | NUM       { $$.c = $1.c; }
  | '-' NUM   { $$.c = vazio + "0" + $2.c + "-"; }
  | STR       { $$.c = $1.c; }
  | '(' E ')' { $$ = $2; }
  | '{' '}'   { $$.c = vazio + "{}"; }
  | '[' ']'   { $$.c = vazio + "[]"; }
  | CALLFUNC  
  ;

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

vector<string> conserta_argumentos( vector<string> pilha ) {
  string elemento = "indice";
  for( int i = 0; i < count_args; i++ ) {
    auto busca = find( pilha.begin(), pilha.end(), elemento );
    if( busca != pilha.end() ) {
      int indice = busca - pilha.begin();
      pilha.at( indice ) = to_string(i);
    }
  }
  return pilha;
}

string trim( string str_inicial, string remover ) {
  for ( int i = 0; i < remover.length(); i++ ) {
    str_inicial.erase( remove( str_inicial.begin(), str_inicial.end(), remover[i] ), str_inicial.end() );
  }
  return str_inicial;
}

vector<string> tokeniza( string str ) {
    string separador = " ";
    size_t pos = 0;
    string palavra;
    vector<string> palavras;

    while( (pos = str.find( separador )) != string::npos ) {
        palavra = str.substr( 0, pos );
        palavras.push_back( palavra );
        str.erase( 0, pos + separador.length() );
    }

    palavras.push_back( str );

    return palavras;
}

int main( int argc, char* argv[] ) {
  yyparse();

  return 0;
}