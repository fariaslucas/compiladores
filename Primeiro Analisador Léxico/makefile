all: saida
	./saida

lex.yy.c: scan.lex
	lex scan.lex

saida: lex.yy.c main.cc 
	g++ -Wall -std=c++17 main.cc -o saida -lfl
	
clean:
	rm saida lex.yy.c