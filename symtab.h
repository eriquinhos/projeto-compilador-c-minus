#include <stdio.h>
#include <stdlib.h>

#ifndef _SYMTAB_H_
#define _SYMTAB_H_


/*Procedimento st_insert insere enumeração de linhas e localizações de memória na tabela de símbolos
loc = localização de memória é inserida apenas na primeira vez, caso contrário é ignorada */

void st_insert(char*, int, int);

/*Função st_lookup retorna a localização na memória de uma variável ou -1 se não encontrar*/
int st_lookup(char*);

/*Procedimento printSymTab imprime o conteúdo da tabela de símbolos */
void printSymTab(FILE*);
#endif