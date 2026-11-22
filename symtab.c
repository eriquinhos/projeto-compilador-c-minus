#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

#define SIZE 211
#define SHIFT 4

/*a função hashing*/
static int hash(char *chave){
  int temp = 0;
  int i = 0;
  while(chave[i] != '\0')
  {
    temp = ((temp << SHIFT) + chave[i]) % SIZE;
    i++;
  }
  return temp;
}

/* lista de numero de linhas no código-fonte */
typedef struct LineListRec{
  int linhano;
  struct LineListRec *prox;
}*LineList;

/* registro nas listas de repositórios para cada variável 
nome | localização atribuida | lista de linhas */
typedef struct BucketListRec{
  char *nome;
  LineList linhas;
  int memloc;  // localização atribuida na memória
  struct BucketListRec *prox;
}*BucketList;

/* tabela de hashing*/
static BucketList hashTable[SIZE];

void st_insert(char *name, int lineno, int memloc){
  int h = hash(name);
  BucketList l = hashTable[h];
  while((l != NULL) && (strcmp(name, l->nome) != 0))
    l = l->prox;
  
  if(l == NULL){ // se a variável não está na tabela, insere
    l = (BucketList) malloc(sizeof(struct BucketListRec));
    l->nome = strdup(name);
    l->linhas = (LineList) malloc(sizeof(struct LineListRec));
    l->linhas->linhano = lineno;
    l->linhas->prox = NULL;
    l->memloc = memloc;
    l->prox = hashTable[h];
    hashTable[h] = l;
  }
  else{ //variável já está na tabela, adiciona nova linha
    LineList t = l->linhas;
    while(t->prox != NULL)
      t = t->prox;
    t->prox = (LineList) malloc(sizeof(struct LineListRec));
    t->prox->linhano = lineno;
    t->prox->prox = NULL;
  }
}

int st_lookup(char *name){
  int h = hash(name);
  BucketList l = hashTable[h];
  while((l != NULL) && (strcmp(name, l->nome) != 0))
    l = l->prox;
  if(l == NULL)
    return -1;
  else
    return l->memloc;
}

void printSymTab(FILE *f){
  int i;
  fprintf(f, "Nome da variável  Localização na memória  Numero da linha\n");
  fprintf(f, "----------------  ----------------------  ---------------\n");
  for(i = 0; i < SIZE; i++){
    BucketList l = hashTable[i];
    while(l != NULL){
      LineList t = l->linhas;
      fprintf(f, "%-14s               ", l->nome);
      fprintf(f, "%-8d              ", l->memloc);
      while(t != NULL){
        fprintf(f, "%4d             ", t->linhano);
        t = t->prox;
      }
      fprintf(f, "\n");
      l = l->prox;
    }
  }
}