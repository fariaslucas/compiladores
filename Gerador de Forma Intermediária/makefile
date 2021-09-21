all: tradutor
	./tradutor < programa.txt

lex.yy.c: tradutor.l
		lex tradutor.l

tradutor: lex.yy.c 
		g++ lex.yy.c -o tradutor -ll

clean: 
	rm tradutor lex.yy.c