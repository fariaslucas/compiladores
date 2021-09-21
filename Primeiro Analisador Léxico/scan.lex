/* Coloque aqui definições regulares */

WS     [ \t\n]

DIG    [0-9]
LET    [A-Za-z_$]

ID     {LET}({LET}|{DIG})*
INT    {DIG}+
FLOAT  {INT}("."{INT})?([Ee]("+"|"-")?{INT})?

FOR    [Ff][Oo][Rr]
IF     [Ii][Ff]

COMENT ("//"(.)*)|("/*"([^*]|[*][^/])*"*/")

STRING ["]([^"\n\\]|["]["]|\\([^\n]|["]))*["]

FUNC   {ID}"("


%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}     { /* ignora espaços, tabs e '\n' */ }

{INT}    { return _INT; }
{FLOAT}  { return _FLOAT; }

{FOR}    { return _FOR; }
{IF}     { return _IF; }

">="     { return _MAIG; }
"<="     { return _MEIG; }
"=="     { return _IG; }
"!="     { return _DIF; }

{COMENT} { return _COMENTARIO; }
{STRING} { return _STRING; }
{FUNC}   { return _FUNC; }

{ID}     { return _ID; }

.        { return *yytext;
           /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */