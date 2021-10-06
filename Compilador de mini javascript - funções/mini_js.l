DIG     [0-9]
LETRA   [A-Za-z_]

ID      {LETRA}({LETRA}|{DIG})*
NUM     {DIG}+("."{DIG}+)?
STR     (\"([^\"\n]|(\\\")|\"\")+\")|('([^'\n]|''|\\')*')

%%

"\n"        { linha++; coluna = 1; }
"\t"        { coluna += 4; }
" "         { coluna++; }

"asm{".*"}" { string lexema = trim( yytext + 3, "{}" ); 
              yylval.c = tokeniza( lexema );
              coluna += strlen( yytext ); 
              return ASM; }

{STR} 	    { yylval.c = vazio + yytext; 
              return STR; }

{NUM}   	{ yylval.c = vazio + yytext; 
              return NUM; }

"=="        { yylval.c = vazio + "==";
              return IG; }

"!="        { yylval.c = vazio + "!=";
              return DIF; }

">="        { yylval.c = vazio + ">=";
              return MAIG;}

"<="        { yylval.c = vazio + "<=";
              return MEIG;}

"=>"        { yylval.c = vazio + "=>";
              return SETA;}

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

"function"  { yylval.c = vazio + "function"; 
              return FUNCTION;}

"return"    { yylval.c = vazio + "return"; 
              return RETURN;}

{ID}		{ yylval.c = vazio + yytext; 
              return ID; }

.       	{ yylval.c = vazio + yytext; 
              return *yytext; }

%%