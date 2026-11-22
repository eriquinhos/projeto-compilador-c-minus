%code requires {
  #include "ast.h"
}

%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>

  int yylex(void);
  void yyerror(const char *s);
  extern int line_num;
  extern char *yytext;
%}

%code {
  static TreeNode *savedTree;  // raiz da árvore sintática

  /* Cria o nó binário usado por operadores aritméticos e relacionais */
  static TreeNode *newOpNode(TreeNode *left, OpType op, TreeNode *right, int lineno) {
    TreeNode *t = newExpNode(OpK, lineno);
    t->child[0] = left;
    t->child[1] = right;
    t->attr.op = op;
    return t;
  }
}

%locations
%expect 1

%union {
  int ival;
  char *sval;
  TreeNode *node;
  OpType op;
  ExpType type;
}

%token INT VOID IF ELSE WHILE RETURN
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token SEMICOLON COMMA
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token LT LE GT GE EQ NE
%token <ival> NUMBER
%token <sval> ID

%type <type> tipo_especificador
%type <op> relacional soma mult
%type <node> declaracao_lista declaracao var_declaracao fun_declaracao
%type <node> params param_lista param composto_decl local_declaracoes statement_lista
%type <node> statement expressao_decl selecao_decl iteracao_decl retorno_decl
%type <node> expressao var simples_expressao soma_expressao termo fator ativacao
%type <node> args arg_lista

%start programa

%%
programa:
  declaracao_lista { savedTree = $1; }
;

declaracao_lista:
  declaracao_lista declaracao { $$ = appendSibling($1, $2); }
  | declaracao
;

declaracao:
  var_declaracao
  | fun_declaracao
;

var_declaracao:
  tipo_especificador ID SEMICOLON {
    $$ = newDeclNode(VarK, @2.first_line);
    $$->type = $1;
    $$->attr.name = $2;
  }
  | tipo_especificador ID LBRACKET NUMBER RBRACKET SEMICOLON {
    $$ = newDeclNode(VarK, @2.first_line);
    $$->type = $1;
    $$->attr.name = $2;
    $$->isArray = 1;
    $$->arraySize = $4;
  }
;

tipo_especificador:
  INT { $$ = Integer; }
  | VOID { $$ = Void; }
;

fun_declaracao:
  tipo_especificador ID LPAREN params RPAREN composto_decl {
    $$ = newDeclNode(FunK, @2.first_line);
    $$->type = $1;
    $$->attr.name = $2;
    $$->child[0] = $4;
    $$->child[1] = $6;
  }
;

params:
  param_lista
  | VOID { $$ = NULL; }
 ;
 
 param_lista:
  param_lista COMMA param { $$ = appendSibling($1, $3); }
  | param
;

param:
  tipo_especificador ID {
    $$ = newDeclNode(ParamK, @2.first_line);
    $$->type = $1;
    $$->attr.name = $2;
  }
  | tipo_especificador ID LBRACKET RBRACKET {
    $$ = newDeclNode(ParamK, @2.first_line);
    $$->type = $1;
    $$->attr.name = $2;
    $$->isArray = 1;
  }
;

composto_decl:
  LBRACE local_declaracoes statement_lista RBRACE {
    $$ = newStmtNode(CompoundK, @1.first_line);
    $$->child[0] = $2;
    $$->child[1] = $3;
  }
;

local_declaracoes:
  local_declaracoes var_declaracao { $$ = appendSibling($1, $2); }
  | %empty { $$ = NULL; }
;

statement_lista:
  statement_lista statement { $$ = appendSibling($1, $2); }
  | %empty { $$ = NULL; }
;

statement:
  expressao_decl
  | composto_decl
  | selecao_decl
  | iteracao_decl
  | retorno_decl
;

expressao_decl:
  expressao SEMICOLON { $$ = $1; }
  | SEMICOLON { $$ = NULL; }
;

selecao_decl:
  IF LPAREN expressao RPAREN statement {
    $$ = newStmtNode(IfK, @1.first_line);
    $$->child[0] = $3;
    $$->child[1] = $5;
  }
  | IF LPAREN expressao RPAREN statement ELSE statement {
    $$ = newStmtNode(IfK, @1.first_line);
    $$->child[0] = $3;
    $$->child[1] = $5;
    $$->child[2] = $7;
  }
;
iteracao_decl:
  WHILE LPAREN expressao RPAREN statement {
    $$ = newStmtNode(WhileK, @1.first_line);
    $$->child[0] = $3;
    $$->child[1] = $5;
  }
;

retorno_decl:
  RETURN SEMICOLON { $$ = newStmtNode(ReturnK, @1.first_line); }
  | RETURN expressao SEMICOLON {
    $$ = newStmtNode(ReturnK, @1.first_line);
    $$->child[0] = $2;
  }
;

expressao:
  var ASSIGN expressao {
    $$ = newExpNode(AssignK, @2.first_line);
    $$->child[0] = $1;
    $$->child[1] = $3;
  }
  | simples_expressao
;

var:
  ID {
    $$ = newExpNode(IdK, @1.first_line);
    $$->attr.name = $1;
  }
  | ID LBRACKET expressao RBRACKET {
    $$ = newExpNode(IdK, @1.first_line);
    $$->attr.name = $1;
    $$->child[0] = $3;
  }
;

simples_expressao:
  soma_expressao relacional soma_expressao { $$ = newOpNode($1, $2, $3, @2.first_line); }
  | soma_expressao
;

relacional:
  LT { $$ = LtOp; }
  | LE { $$ = LeOp; }
  | GT { $$ = GtOp; }
  | GE { $$ = GeOp; }
  | EQ { $$ = EqOp; }
  | NE { $$ = NeOp; }
;

soma_expressao:
  soma_expressao soma termo { $$ = newOpNode($1, $2, $3, @2.first_line); }
  | termo
;

soma:
  PLUS { $$ = PlusOp; }
  | MINUS { $$ = MinusOp; }
;

termo:
  termo mult fator { $$ = newOpNode($1, $2, $3, @2.first_line); }
  | fator
;

mult:
  MULTIPLY { $$ = TimesOp; }
  | DIVIDE { $$ = OverOp; }
;

fator:
  LPAREN expressao RPAREN { $$ = $2; }
  | var
  | ativacao
  | NUMBER {
    $$ = newExpNode(ConstK, @1.first_line);
    $$->attr.val = $1;
  }
;

ativacao:
  ID LPAREN args RPAREN {
    $$ = newExpNode(CallK, @1.first_line);
    $$->attr.name = $1;
    $$->child[0] = $3;
  }
;

args:
  arg_lista
  | %empty { $$ = NULL; }
;

arg_lista:
  arg_lista COMMA expressao { $$ = appendSibling($1, $3); }
  | expressao
;

%%
void yyerror(const char *s) {
  fprintf(stderr, "ERRO SINTÁTICO: %s LINHA: %d (%s)\n",
          yychar == YYEOF ? "fim de arquivo" : yytext, line_num, s);
}

int main(void) {
  int resultado = yyparse();

  if (resultado == 0) {
    printf("Análise sintática concluída.\n\nÁrvore sintática:\n");
    printTree(stdout, savedTree);
  }

  return resultado;
}