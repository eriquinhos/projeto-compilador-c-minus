#ifndef AST_H
#define AST_H
#include <stdio.h>

/* Os nomes dos enums abaixo não podem coincidir com os tokens do Bison (IF, ID, PLUS...) */
typedef enum { StmtK, ExpK, DeclK } NodeKind;
typedef enum { IfK, WhileK, ReturnK, CompoundK } StmtKind;
typedef enum { OpK, ConstK, IdK, AssignK, CallK } ExpKind;
typedef enum { VarK, FunK, ParamK } DeclKind;

/* Operadores binários de C- */
typedef enum {
  PlusOp, MinusOp, TimesOp, OverOp,
  LtOp, LeOp, GtOp, GeOp, EqOp, NeOp
} OpType;

/* C- só tem int e void. Em declarações é o tipo declarado (o de retorno, no caso de funções) */
typedef enum { Void, Integer } ExpType;

#define MAXCHILDREN 3

/*
 * Filhos por tipo de nó (os demais ficam NULL):
 *   IfK       child[0] condição, child[1] then, child[2] else
 *   WhileK    child[0] condição, child[1] corpo
 *   ReturnK   child[0] expressão (opcional)
 *   CompoundK child[0] declarações locais, child[1] comandos
 *   OpK       child[0] operando esquerdo, child[1] operando direito
 *   AssignK   child[0] variável (IdK), child[1] expressão
 *   IdK       child[0] índice, se for acesso a vetor
 *   CallK     child[0] argumentos
 *   FunK      child[0] parâmetros, child[1] corpo (CompoundK)
 * Listas (declarações, comandos, parâmetros, argumentos) são encadeadas por sibling.
 */
typedef struct treeNode {
  struct treeNode *child[MAXCHILDREN];
  struct treeNode *sibling;
  int lineno;
  NodeKind nodekind;
  union {
    StmtKind stmt;
    ExpKind exp;
    DeclKind decl;
  } kind;
  union {
    OpType op;   // OpK
    int val;     // ConstK
    char *name;  // IdK, CallK e declarações
  } attr;
  ExpType type;   // tipo declarado (declarações) ou calculado na análise semântica
  int isArray;    // VarK/ParamK: 1 se for vetor
  int arraySize;  // VarK vetor: número de posições
} TreeNode;

TreeNode * newStmtNode(StmtKind, int lineno);  // cria um novo nó de comando
TreeNode * newExpNode(ExpKind, int lineno);    // cria um novo nó de expressão
TreeNode * newDeclNode(DeclKind, int lineno);  // cria um novo nó de declaração
char * copyString(const char*);                // cria uma cópia de uma string
TreeNode * appendSibling(TreeNode *list, TreeNode *node);  // anexa node ao fim de list e devolve a cabeça
void printTree(FILE*, TreeNode*);              // imprime a árvore sintática

#endif
