all: saida entrada.txt
	./saida < entrada.txt

saida: lex.yy.c y.tab.c
	g++ y.tab.c -o saida -ll
	
lex.yy.c: mini_js.l
	lex mini_js.l
	
y.tab.c: mini_js.y
	yacc mini_js.y
	
clean: 
	rm -f lex.yy.c y.tab.c saida