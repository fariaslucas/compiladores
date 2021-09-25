WS      [ \t]

DIG     [0-9]
LETRA   [A-Za-z_]

ID      {LETRA}({LETRA}|{DIG})*
NUM     {DIG}+("."{DIG}+)?
STR     (\"([^\"\n]|(\\\")|\"\")+\")|('([^'\n]|''|\\')*')

%%

{WS}		{ /* ignora espaços e tabs */ }

"\n"        { linha++; }

{STR} 	    { yylval.c = vazio + yytext; 
              return STR; }

{NUM}   	{ yylval.c = vazio + yytext; 
              return NUM; }

"=="        { yylval.c = vazio + "==";
              return IGUAL; }

"let"       { yylval.c = vazio + "let"; 
              return LET; }

"if"        { yylval.c = vazio + "if"; 
              return IF; } 

"else"      { yylval.c = vazio + "else"; 
              return ELSE; }

"while"     { yylval.c = vazio + "while"; 
              return WHILE; }

"for"       { yylval.c = vazio + "for"; 
              return FOR; }

{ID}		{ yylval.c = vazio + yytext; 
              return ID; }

.       	{ yylval.c = vazio + yytext; 
              return *yytext; }

%%