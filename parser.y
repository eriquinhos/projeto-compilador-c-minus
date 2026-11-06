%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>

  int yylex(void);
  void yyerror(const char *s);
%}

%token INT VOID IF ELSE WHILE RETURN
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token SEMICOLON COMMA
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token LT LE GT GE EQ NE
%token NUMBER
%token ID

%start programa

%%
programa:
  declaracao_lista
;

declaracao_lista:
  declaracao_lista declaracao
  | declaracao
;

declaracao:
  var_declaracao
  | fun_declaracao
;

var_declaracao:
  tipo_especificador ID SEMICOLON
  |  tipo_especificador ID LBRACKET NUMBER RBRACKET SEMICOLON
;

tipo_especificador:
  INT
  | VOID
;

fun_declaracao:
  tipo_especificador ID LPAREN params RPAREN composto_decl
;

params:
  param_lista
  |VOID
 ;
 
 param_lista:
  param_lista COMMA param
  | param
;

param:
  tipo_especificador ID
  | tipo_especificador ID LBRACKET RBRACKET
;

composto_decl:
  LBRACE local_declaracoes statement_lista RBRACE
;

local_declaracoes:
  local_declaracoes var_declaracao
  | %empty
;

statement_lista:
  statement_lista statement
  | %empty
;

statement:
  expressao_decl
  | composto_decl
  | selecao_decl
  | iteracao_decl
  | retorno_decl
;

expressao_decl:
  expressao SEMICOLON
  | SEMICOLON
;

selecao_decl:
  IF LPAREN expressao RPAREN statement
  | IF LPAREN expressao RPAREN statement ELSE statement
;
iteracao_decl:
  WHILE LPAREN expressao RPAREN statement
;

retorno_decl:
  RETURN SEMICOLON
  | RETURN expressao SEMICOLON
;

expressao:
  ID ASSIGN expressao
  | simples_expressao
;

simples_expressao:
  soma_expressao relacional soma_expressao
  | soma_expressao
;

relacional:
  LT
  | LE
  | GT
  | GE
  | EQ
  | NE
;

soma_expressao:
  soma_expressao soma termo
  | termo
;

soma:
  PLUS
  | MINUS
;

termo:
  termo mult fator
  | fator
;

mult:
  MULTIPLY
  | DIVIDE
;

fator:
  LPAREN expressao RPAREN
  | ID
  | ativacao
  | NUMBER
;

ativacao:
  ID LPAREN args RPAREN
;

args:
  arg_lista
  | %empty
;

arg_lista:
  arg_lista COMMA expressao
  | expressao
;

%%
void yyerror(const char *s) {
  fprintf(stderr, "ERRO SINTÁTICO: %s\n", s);
}