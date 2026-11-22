#include <stdlib.h>
#include <string.h>
#include "ast.h"

static void outOfMemory(void) {
  fprintf(stderr, "ERRO: memória insuficiente\n");
  exit(1);
}


static TreeNode * newNode(NodeKind nodekind, int lineno) {
  TreeNode *t = (TreeNode *) calloc(1, sizeof(TreeNode));
  if (t == NULL) outOfMemory();
  t->nodekind = nodekind;
  t->lineno = lineno;
  return t;
}

TreeNode * newStmtNode(StmtKind kind, int lineno) {
  TreeNode *t = newNode(StmtK, lineno);
  t->kind.stmt = kind;
  return t;
}

TreeNode * newExpNode(ExpKind kind, int lineno) {
  TreeNode *t = newNode(ExpK, lineno);
  t->kind.exp = kind;
  return t;
}

TreeNode * newDeclNode(DeclKind kind, int lineno) {
  TreeNode *t = newNode(DeclK, lineno);
  t->kind.decl = kind;
  return t;
}

char * copyString(const char *s) {
  char *t;
  if (s == NULL) return NULL;
  t = (char *) malloc(strlen(s) + 1);
  if (t == NULL) outOfMemory();
  strcpy(t, s);
  return t;
}

/* node pode ser NULL (comando vazio), caso em que a lista fica como está */
TreeNode * appendSibling(TreeNode *list, TreeNode *node) {
  TreeNode *t = list;
  if (node == NULL) return list;
  if (list == NULL) return node;
  while (t->sibling != NULL) t = t->sibling;
  t->sibling = node;
  return list;
}

static const char * typeName(ExpType type) {
  return type == Integer ? "int" : "void";
}

static const char * opName(OpType op) {
  switch (op) {
    case PlusOp:  return "+";
    case MinusOp: return "-";
    case TimesOp: return "*";
    case OverOp:  return "/";
    case LtOp:    return "<";
    case LeOp:    return "<=";
    case GtOp:    return ">";
    case GeOp:    return ">=";
    case EqOp:    return "==";
    case NeOp:    return "!=";
  }
  return "?";
}

static void printDecl(FILE *f, TreeNode *t) {
  const char *label = t->kind.decl == FunK ? "Func" :
                      t->kind.decl == ParamK ? "Param" : "Var";
  fprintf(f, "%s: %s", label, t->attr.name);
  if (t->kind.decl == VarK && t->isArray) fprintf(f, "[%d]", t->arraySize);
  else if (t->isArray) fprintf(f, "[]");
  fprintf(f, " (%s)\n", typeName(t->type));
}

static void printStmt(FILE *f, TreeNode *t) {
  switch (t->kind.stmt) {
    case IfK:       fprintf(f, "If\n"); break;
    case WhileK:    fprintf(f, "While\n"); break;
    case ReturnK:   fprintf(f, "Return\n"); break;
    case CompoundK: fprintf(f, "Compound\n"); break;
  }
}

static void printExp(FILE *f, TreeNode *t) {
  switch (t->kind.exp) {
    case OpK:     fprintf(f, "Op: %s\n", opName(t->attr.op)); break;
    case ConstK:  fprintf(f, "Const: %d\n", t->attr.val); break;
    case IdK:     fprintf(f, "%s: %s\n", t->child[0] ? "Array Id" : "Id", t->attr.name); break;
    case AssignK: fprintf(f, "Assign\n"); break;
    case CallK:   fprintf(f, "Call: %s\n", t->attr.name); break;
  }
}

static void printNode(FILE *f, TreeNode *t, int indent) {
  int i;
  for (; t != NULL; t = t->sibling) {
    fprintf(f, "%*s", indent, "");
    switch (t->nodekind) {
      case DeclK: printDecl(f, t); break;
      case StmtK: printStmt(f, t); break;
      case ExpK:  printExp(f, t); break;
    }
    for (i = 0; i < MAXCHILDREN; i++) printNode(f, t->child[i], indent + 2);
  }
}

void printTree(FILE *f, TreeNode *tree) {
  printNode(f, tree, 0);
}
