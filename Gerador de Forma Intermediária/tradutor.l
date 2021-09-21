%{
    #include <iostream>
    #include <string>

    using namespace std;

    int tk;
    string lexema;

    int token( int );
    void casa( int );

    void A();
    void E();
    void T();
    void F();

    enum TOKEN { _ID = 256, _NUM, _STR };  

%}

WS  [ \t\n]

DIG [0-9]
LET [A-Za-z_$]

ID  {LET}({LET}|{DIG})*
NUM {DIG}+("."{DIG}+)?

STR \"([^\"\n]|(\\\")|\"\")+\"

%%

{WS}    { /* ignora espaços, tabs e '\n' */ }

{NUM}   { return token( _NUM ); }
{STR}   { return token( _STR ); }

{ID}    { return token( _ID ); }

.       { return token( *yytext ); }

%%

int token( int tk ) {  
  lexema = yytext; 

  return tk;
}

void casa( int esperado ) {
    if( tk == esperado )
        tk = yylex();
    else {
        cout << "Esperado " << esperado << " , encontrado: " << tk << endl;
        exit( 1 );
    }
}

void A() {
    string temp;

    if ( lexema == "print" ) {
        temp = lexema;
        casa( _ID ); 
        E();
        cout << temp << " # ";
        
    } else {
        temp = lexema;
        casa( _ID );
        cout << temp << " ";
        casa( '=' );
        E();
        cout << "= ";
    }

    casa( ';' );
}

void E() {
    T();

    while( 1 ) {
        switch( tk ) {
        case '+':
            casa( '+' );
            T();
            cout << "+ ";
            break;

        case '-':
            casa( '-' );
            T();
            cout << "- ";
            break;

        default:
            return;
        }
    }
}

void T() {
    F();
    
    while( 1 ) {
        switch( tk ) {
        case '*': 
            casa( '*' );
            F();
            cout << "* ";
            break;

        case '/':
            casa( '/' );
            F();
            cout << "/ ";
            break;

        case ',':
            casa( ',' );
            F();
            break;

        default:
            return;
        }
    }
}

void F() {
    switch ( tk ) {
        case _ID: {
            string temp = lexema;
            casa( _ID );
            if ( lexema == "(" ){
                F();
                cout << temp << " # ";
                break;
            }
            cout << temp << " @ ";
        }   break;

        case _NUM: {
            string temp = lexema;
            casa( _NUM );
            cout << temp << " ";
        }   break;

        case _STR: {
            string temp = lexema;
            casa( _STR );
            cout << temp << " ";
        }   break;

        case '(':
            casa( '(' );
            E();
            casa( ')' );
            break;

        default:
            cout << "Instrução ou operador inválido: " << lexema;
            exit( 1 );
    }
}

int main() {
    tk = yylex();

    while( tk != 0 )
        A();

    return 0;
}