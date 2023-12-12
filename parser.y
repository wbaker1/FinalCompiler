%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbolTable.h"
#include "AST.h"
#include "IRcode.h"
#include "Assembly.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;

FILE * IRcode;
FILE * MIPScode;


void yyerror(const char* s);
char currentScope[50]; // "global" or the name of the function
int semanticCheckPassed = 1; // flags to record correctness of semantic checks
%}

%union {
	int number;
	float fl;
	char character;
	char* string;
	struct AST* ast;
}

%token <string> TYPE
%token <string> ID
%token <string> UNARY
%token <character> SEMICOLON
%token <character> COLON
%token <character> LEFTPAREN
%token <character> RIGHTPAREN
%token <character> LEFTBRACKET
%token <character> RIGHTBRACKET
%token <character> LEFTCBRACE
%token <character> RIGHTCBRACE
%token <character> EQ 
%token <character> COMMA 
%token <character> QUOTE
%token <string> PLUS
%token <string> MINUS
%token <string> MULT
%token <string> DIVIDE
%token <string> LT
%token <string> GT
%token <string> EQUIV
%token <number> INTEGER
%token <fl> NUMBER
%token <string> CHARACTER
%token <string> WRITE
%token <string> WRITELN
%token <string> RETURN
%token <string> IF
%token <string> ENDIF
%token <string> ELSE
%token <string> ENDELSE
%token <string> WHILE
%token <string> ENDWHILE
%token <string> READ

%left PLUS MINUS
%left MULT DIVIDE

%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } INTEGER;
%printer { fprintf(yyoutput, "%f", $$); } NUMBER;
%printer { fprintf(yyoutput, "%s", $$); } CHARACTER;

%type <ast> Program DeclList NFDeclList Decl NFDecl VarDecl FuncDecl ParamDeclList ParamDeclListTail ParamDecl ParamList ParamListTail Return Stmt StmtList Expr Arith Primary ArithOp CompOp

%start Program

%%

Program: DeclList  { $$ = $1;
					 printf("\n--- Abstract Syntax Tree ---\n\n");
					 printAST($$,0);
					}
;

DeclList:	Decl DeclList	{ $1->left = $2;
							  $$ = $1;
							}
	| Decl	{ $$ = $1; }
;

NFDeclList:	NFDecl NFDeclList	{ $1->left = $2;
							  $$ = $1;
							}
	| NFDecl	{ $$ = $1; }
;

Decl:	VarDecl
	| FuncDecl
	| StmtList
	| Return
;

NFDecl:	VarDecl
	| StmtList
;

VarDecl:	TYPE ID SEMICOLON	{ printf("\n RECOGNIZED RULE: Variable declaration %s\n", $2);
									// Symbol Table
									symTabAccess();
									int inSymTab = found($2, currentScope);
									//printf("looking for %s in symtab - found: %d \n", $2, inSymTab);
									
									if (inSymTab == 0) 
										addItem($2, "Var", $1,0, currentScope);
									else
										printf("SEMANTIC ERROR: Var %s is already in the symbol table", $2);
									showSymTable();
									
								  // ---- SEMANTIC ACTIONS by PARSER ----
								    $$ = AST_Type("Type",$1,$2);
									printf("-----------> %s", $$->LHS);
																	
								}

		| TYPE ID LEFTBRACKET INTEGER RIGHTBRACKET SEMICOLON { printf("\n RECOGNIZED RULE: Variable declaration %s\n", $2);
									// Symbol Table
									symTabAccess();
									int inSymTab = found($2, currentScope);
									//printf("looking for %s in symtab - found: %d \n", $2, inSymTab);
									
									if (inSymTab == 0) 
										addItem($2, "Array", $1, $4, currentScope);
									else
										printf("SEMANTIC ERROR: Array %s is already in the symbol table", $2);
									showSymTable();
									
								  // ---- SEMANTIC ACTIONS by PARSER ----
								    $$ = AST_Type("Type",$1,$2);
									printf("-----------> %s", $$->LHS);
									char str[50];
									int cnt = $4;
									cnt *= 4;
									sprintf(str, "%d", cnt);
									arrayIRCount($2, str);
									arrayCount($2, str);
								}
;

FuncDecl:	TYPE ID LEFTPAREN ParamDeclList RIGHTPAREN COLON 	{ printf("\n RECOGNIZED RULE: Function declaration %s\n", $2);
																	// Symbol Table
																	symTabAccess();
																	int inSymTab = found($2, currentScope);
																	//printf("looking for %s in symtab - found: %d \n", $2, inSymTab);
									
																	if (inSymTab == 0) 
																		addItem($2, "Func", $1,0, currentScope);
																	else
																		printf("SEMANTIC ERROR: Func %s is already in the symbol table", $2);
																	showSymTable();
									
																  // ---- SEMANTIC ACTIONS by PARSER ----
																	$$ = AST_Func("Type", $2, "Params");
																	printf("-----------> %s", $$->LHS);
																	functionDeclarationIR($2);
																	functionDeclarationMIPS($2);
																}
;

ParamDeclList:	
			| ParamDeclListTail
;

ParamDeclListTail:	ParamDecl
				| ParamDecl COMMA ParamDeclListTail
;

ParamDecl:	TYPE ID
		| TYPE ID LEFTBRACKET INTEGER RIGHTBRACKET
;

ParamList:
		| ParamListTail
;

ParamListTail: ID
		| ID COMMA ParamListTail
;

Return:	RETURN ID SEMICOLON	{ printf("\n RECOGNIZED RULE: WRITE statement\n");
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  
					$$ = AST_Type("function",$1,$2);
					// Check if identifiers have been declared
					    if(found($2, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $2, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							returnIR($2);
							returnMIPS($2);
						}
				}
;

StmtList:	
	| Stmt StmtList
;

Stmt:	SEMICOLON	{}
	| Expr SEMICOLON	{$$ = $1;}
	| IF LEFTPAREN ID CompOp INTEGER RIGHTPAREN COLON 	{ printf("\n RECOGNIZED RULE: IF statement\n");
					char str[50];
					sprintf(str, "%d", $5);
					$$ = AST_Write($4,$3,str);
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							char num[50];
							sprintf(num, "%d", $5);

							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							IRIDINTIf($3, $4, num);
							MIPSIDINTIf($3, $4, num);
						}
				}
	| IF LEFTPAREN ID CompOp ID RIGHTPAREN COLON 	{ printf("\n RECOGNIZED RULE: IF statement\n");
					$$ = AST_Write($4,$3,$5);
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							

							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							IRIDIDIf($3, $4, $5);
							MIPSIDIDIf($3, $4, $5);
						}
				}
	| ENDIF ELSE COLON {
					printf("\n RECOGNIZED RULE: IF ELSE statement\n");
	}

	| WHILE LEFTPAREN ID CompOp INTEGER RIGHTPAREN COLON 	{ printf("\n RECOGNIZED RULE: WHILE statement\n");
					char str[50];
					sprintf(str, "%d", $5);
					$$ = AST_Write($4,$3,str);
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							char num[50];
							sprintf(num, "%d", $5);

							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							IRIDINTWhile($3, $4, num);
							MIPSIDINTWhile($3, $4, num);
						}
				}
	| WHILE LEFTPAREN ID CompOp ID RIGHTPAREN COLON 	{ printf("\n RECOGNIZED RULE: WHILE statement\n");
					$$ = AST_Write($4,$3,$5);
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
						
							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							IRIDIDWhile($3, $4, $5);
							MIPSIDIDWhile($3, $4, $5);
						}
				}
;

Expr:	ENDIF	{
		MIPSEndIf();
		IREndIf();
	}

	|	ENDELSE	{
	}

	| ENDWHILE	{	printf("\n RECOGNIZED RULE: ENDWHILE statement\n");
		MIPSEndWhile();
		IREndWhile();
	}

	| ID EQ ID 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_assignment("=",$1,$3);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRAssignment(id1, id2);
						emitMIPSAssignment(id1, id2);



					}
					

				}

	| ID EQ ID LEFTBRACKET INTEGER RIGHTBRACKET 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_assignment("=",$1,$3);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRAssignment(id1, id2);
						emitMIPSAssignment(id1, id2);

					}					

				}

	| ID EQ INTEGER 	{ printf("\n RECOGNIZED RULE: Constant Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   
					   sprintf(str, "%d", $3); // convert $3 from int to string
					   $$ = AST_assignment("=",$1, str);

						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types
																		
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $3);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRConstantIntAssignment(id1, id2);
							emitMIPSConstantIntAssignment(id1, id2);

						}
					}

	| ID EQ NUMBER 	{ printf("\n RECOGNIZED RULE: Constant Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   
					   sprintf(str, "%f", $3); // convert $3 from int to string
					   $$ = AST_assignment("=",$1, str);

						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types						
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%f", $3);
							printf("\n%f\n", $3);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							floatCount(id1, id2);
							emitIRConstantFlAssignment(id1, id2);
							emitMIPSConstantFlAssignment(id1, id2);

						}
					}

	/*| ID EQ CHARACTER 	{ printf("\n RECOGNIZED RULE: Char Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   strncpy(str, $3, sizeof(str) - 1); // Copy at most 49 characters to str
					   str[sizeof(str) - 1] = '\0';
					   char let = str[1];
					   
					   $$ = AST_assignmentC("=", $1, let);

						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							//sprintf(id2, "%s", $4);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							//emitMIPSConstantIntAssignment(id1, $4);

						}
					}*/

	| ID EQ ID LEFTPAREN ParamList RIGHTPAREN 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_Func("=",$1,$3);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Function %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						MIPSIDFuncAssignment($1, $3);
						IRIDFuncAssignment($1, $3);

					}
				}
					
	| ID EQ Arith { printf("\n RECOGNIZED RULE: Assignment statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----

					  $$ = AST_assignment("=",$1,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
												
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							char id[50];
							sprintf(id, "%s", $1);

							emitIRArithAssignment(id);
							emitMIPSArithAssignment(id);
					  }
				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ ID 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_assignment("=",$1,$6);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
					
					// Check bounds

						printf("\nChecking Bounds: \n");
						int boundsCheck = withinBounds($1,$3);
						if (boundsCheck == 0){
							printf("SEMANTIC ERROR: Index out of bounds for array %s at index %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRArrayAssignmentID(id1, $3, id2);
						emitMIPSArrayAssignmentID(id1, $3, id2);



					}
					

				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ ID LEFTBRACKET INTEGER RIGHTBRACKET	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_assignment("=",$1,$6);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRAssignment(id1, id2);
						emitMIPSAssignment(id1, id2);



					}
					

				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ ID LEFTPAREN ParamList RIGHTPAREN	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ---- //
					  $$ = AST_assignment("=",$1,$6);

					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						char id1[50], id2[50];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRAssignment(id1, id2);
						emitMIPSAssignment(id1, id2);



					}
					

				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ NUMBER 	{ printf("\n RECOGNIZED RULE: Constant Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   
					   sprintf(str, "%d", $6); // convert $6 from int to string
					   $$ = AST_assignment("=",$1, str);

						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRConstantIntAssignment(id1, id2);
							emitMIPSConstantIntAssignment(id1, id2);

						}
					}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ INTEGER 	{ printf("\n RECOGNIZED RULE: Constant Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $6); // convert $6 from int to string
					   $$ = AST_assignment("=", $1, str);
						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented

						// Check bounds

						printf("\nChecking Bounds: \n");
						int boundsCheck = withinBounds($1,$3);
						if (boundsCheck == 0){
							printf("SEMANTIC ERROR: Index out of bounds for array %s at index %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRArrayAssignmentConst(id1, $3 ,id2);
							emitMIPSArrayAssignmentConst(id1, $3 ,id2);

						}
					}

	/*| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ CHARACTER 	{ printf("\n RECOGNIZED RULE: Constant Assignment statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   strncpy(str, $3, sizeof(str) - 1); // Copy at most 49 characters to str
					   str[sizeof(str) - 1] = '\0';
					   char let = str[1];
					   
					   $$ = AST_assignmentC("=", $1, let);

						// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

						// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50];
							sprintf(id1, "%s", $1);
							//sprintf(id2, "%s", $7);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							//emitMIPSConstantIntAssignment(id1, $7);

						}
					}*/

	| ID LEFTBRACKET INTEGER RIGHTBRACKET EQ Arith { printf("\n RECOGNIZED RULE: Assignment statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_assignment("=",$1,"Arith");

					  char id[50];
					  sprintf(id, "%s", $1);

					  emitIRArithAssignment(id);
					  emitMIPSArithAssignment(id);
				}

	| UNARY LEFTPAREN ID RIGHTPAREN 	{ printf("\n RECOGNIZED RULE: UNARY statement\n");
					$$ = AST_Write("Unary",$1,$3);
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							//emitMIPSWriteId($3);
						}
				}

	| WRITE ID 	{ printf("\n RECOGNIZED RULE: WRITE statement\n");
					$$ = AST_Write("write",$2,"");
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($2, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $2, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRWriteId($2);
							emitMIPSWriteId($2);
						}
				}

	| ENDIF	{
		IREndIf();
		MIPSEndIf();
	}

	/*| WRITE Primary EQ EQ Primary 	{ printf("\n RECOGNIZED RULE: WRITE statement\n");
					$$ = AST_Write("write",$2,"");
					
					// ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared
					    if(found($2, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $2, currentScope);
							semanticCheckPassed = 0;
						}

						if(found($5, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $5, currentScope);
							semanticCheckPassed = 0;
						}

					if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file
							
							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							//emitMIPSWriteId($2);
						}
				}*/
;

Arith: ID ArithOp INTEGER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $3); 
					   $$ = AST_BinaryExpression($2, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($2, id1, id2);
							emitMIPSIDNumOperation($2, id1, id2);
							}
					}

	| ID ArithOp NUMBER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $3); 
					   $$ = AST_BinaryExpression($2, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($2, id1, id2);
							emitMIPSIDNumOperation($2, id1, id2);
							}
					}

	| ID ArithOp ID { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($2,$1,$3);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);
						//sprintf(op, "%s", $2);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($2, id1, id2);
						emitMIPSIDIDOperation($2, id1, id2);
					}
				}

	| ID ArithOp ID LEFTPAREN ParamList RIGHTPAREN { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($2,$1,$3);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);
						//sprintf(op, "%s", $2);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($2, id1, id2);
						emitMIPSIDIDOperation($2, id1, id2);
					}
				}

	| INTEGER ArithOp ID { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation($2, id1, id2);
							emitMIPSNumIDBinaryOperation($2, id1, id2);
							}
					}

	| INTEGER ArithOp ID LEFTPAREN ParamList RIGHTPAREN { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation(op, id1, id2);
							emitMIPSNumIDBinaryOperation(op, id1, id2);
							}
					}

	| INTEGER ArithOp INTEGER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str1[50];
					   sprintf(str1, "%d", $1); 
					   char str2[50];
					   sprintf(str2, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str1, str2);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%d", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRBinaryOperation($2, id1, id2);
							emitMIPSBinaryOperation($2, id1, id2);
							}
					}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp INTEGER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $6); 
					   $$ = AST_BinaryExpression($5, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($5, id1, id2);
							emitMIPSIDNumOperation($5, id1, id2);
							}
					}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp NUMBER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $6); 
					   $$ = AST_BinaryExpression($5, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($5, id1, id2);
							emitMIPSIDNumOperation($5, id1, id2);
							}
					}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp ID { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp ID LEFTPAREN ParamList RIGHTPAREN { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp ID LEFTBRACKET INTEGER RIGHTBRACKET { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for Arrays %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| INTEGER ArithOp ID LEFTBRACKET INTEGER RIGHTBRACKET { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation($2, id1, id2);
							emitMIPSNumIDBinaryOperation($2, id1, id2);
							}
					}

	| NUMBER ArithOp NUMBER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str1[50];
					   sprintf(str1, "%d", $1); 
					   char str2[50];
					   sprintf(str2, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str1, str2);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%d", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRBinaryOperation($2, id1, id2);
							emitMIPSBinaryOperation($2, id1, id2);
							}
					}

	| NUMBER ArithOp ID { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation($2, id1, id2);
							emitMIPSNumIDBinaryOperation($2, id1, id2);
							}
					}

	| NUMBER ArithOp ID LEFTBRACKET INTEGER RIGHTBRACKET { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation($2, id1, id2);
							emitMIPSNumIDBinaryOperation($2, id1, id2);
							}
					}

	| NUMBER ArithOp ID LEFTPAREN ParamList RIGHTPAREN { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $1); 
					   $$ = AST_BinaryExpression($2, str, $3);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($3, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumIDBinaryOperation($2, id1, id2);
							emitMIPSNumIDBinaryOperation($2, id1, id2);
							}
					}

	| NUMBER ArithOp Arith { printf("\n RECOGNIZED RULE: Arithmetic statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  char str[50];
					  sprintf(str, "%d", $1); 
					  $$ = AST_BinaryExpression($2,str,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumBinaryOperationArith($2, id1);
							emitMIPSNumBinaryOperationArith($2, id1);
							}
				}

	| ID ArithOp ID LEFTBRACKET INTEGER RIGHTBRACKET { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($2,$1,$3);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($3, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $3, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $3, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $3);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $3);
						//sprintf(op, "%s", $2);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($2, id1, id2);
						emitMIPSIDIDOperation($2, id1, id2);
					}
				}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp INTEGER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $6); 
					   $$ = AST_BinaryExpression($5, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($5, id1, id2);
							emitMIPSIDNumOperation($5, id1, id2);
							}
					}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp NUMBER { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					   // ---- SEMANTIC ACTIONS by PARSER ----
					   char str[50];
					   sprintf(str, "%d", $6); 
					   $$ = AST_BinaryExpression($5, $1, str);

					   // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%d", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRIDNumOperation($5, id1, id2);
							emitMIPSIDNumOperation($5, id1, id2);
							}
					}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp ID { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp ID LEFTPAREN ParamList RIGHTPAREN { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for variables %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp ID LEFTBRACKET INTEGER RIGHTBRACKET { printf("\n RECOGNIZED RULE: Arithmetic statement\n"); 
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5,$1,$6);

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					// Check if identifiers have been declared

					    if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
					    if(found($6, currentScope) != 1){
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $6, currentScope);
							semanticCheckPassed = 0;
						}

					// Check types

						printf("\nChecking types: \n");
						int typeMatch = compareTypes ($1, $6, currentScope);
						if (typeMatch == 0){
							printf("SEMANTIC ERROR: Type mismatch for Arrays %s and %s \n", $1, $6);
							semanticCheckPassed = 0;
						}
						

					if (semanticCheckPassed == 1) {
						printf("\n\n>>> AssignStmt Rule is SEMANTICALLY correct and IR code is emitted! <<<\n\n");

						// ---- EMIT IR 3-ADDRESS CODE ---- //
						
						// The IR code is printed to a separate file

						char id1[50], id2[50], op[1];
						sprintf(id1, "%s", $1);
						sprintf(id2, "%s", $6);
						//sprintf(op, "%s", $5);

						// Temporary variables management will eventually go in here
						// and the paramaters of the function below will change
						// to using T0, ..., T9 variables

						// ----     EMIT MIPS CODE   ----  //

						// The MIPS code is printed to a separate file

						// MIPS registers management will eventually go in here
						// and the paramaters of the function below will change
						// to using $t0, ..., $t9 registers

						emitIRIDIDOperation($5, id1, id2);
						emitMIPSIDIDOperation($5, id1, id2);
					}
				}

	| ID LEFTPAREN ParamList RIGHTPAREN ArithOp Arith { printf("\n RECOGNIZED RULE: Arithmetic statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5, $1,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%s", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRBinaryOperationArith($5, id1);
							emitMIPSBinaryOperationArith($5, id1);
							}
				}

	| ID LEFTBRACKET INTEGER RIGHTBRACKET ArithOp Arith { printf("\n RECOGNIZED RULE: Arithmetic statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($5, $1,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Array %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($6, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%s", $6);
							//sprintf(op, "%s", $5);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRBinaryOperationArith($5, id1);
							emitMIPSBinaryOperationArith($5, id1);
							}
				}

	| ID ArithOp Arith { printf("\n RECOGNIZED RULE: Arithmetic statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  $$ = AST_BinaryExpression($2, $1,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared

					   if(found($1, currentScope) != 1) {
							printf("SEMANTIC ERROR: Variable %s has NOT been declared in scope %s \n", $1, currentScope);
							semanticCheckPassed = 0;
						}
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%s", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRBinaryOperationArith($2, id1);
							emitMIPSBinaryOperationArith($2, id1);
							}
				}

	| INTEGER ArithOp Arith { printf("\n RECOGNIZED RULE: Arithmetic statement\n");
					// ---- SEMANTIC ACTIONS by PARSER ----
					  char str[50];
					  sprintf(str, "%d", $1); 
					  $$ = AST_BinaryExpression($2,str,"Arith");

					  // ---- SEMANTIC ANALYSIS ACTIONS ---- //  

					   // Check if identifiers have been declared
						
						// Check types

						printf("\nChecking types: \n");

						//printf("%s = %s\n", getVariableType($1, currentScope), getVariableType($3, currentScope));
						
						printf("%s = %s\n", "int", "number");  // This temporary for now, until the line above is debugged and uncommented
						
						if (semanticCheckPassed == 1) {
							printf("\n\nRule is semantically correct!\n\n");

							// ---- EMIT IR 3-ADDRESS CODE ---- //
							
							// The IR code is printed to a separate file

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							char id1[50], id2[50], op[1];
							sprintf(id1, "%d", $1);
							sprintf(id2, "%s", $3);
							//sprintf(op, "%s", $2);

							// Temporary variables management will eventually go in here
							// and the paramaters of the function below will change
							// to using T0, ..., T9 variables

							// ----     EMIT MIPS CODE   ----  //

							// The MIPS code is printed to a separate file

							// MIPS registers management will eventually go in here
							// and the paramaters of the function below will change
							// to using $t0, ..., $t9 registers

							emitIRNumBinaryOperationArith($2, id1);
							emitMIPSNumBinaryOperationArith($2, id1);
							}
				}
;

Primary:	ID
	| INTEGER
	| NUMBER
	| ID LEFTBRACKET INTEGER RIGHTBRACKET
;

ArithOp:	PLUS
		| MINUS
		| MULT
		| DIVIDE
;

CompOp:	LT
		| GT
		| EQUIV
;

%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n##### COMPILER STARTED #####\n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}

	// Initialize IR and MIPS files
	initIRFile();
	initAssemblyFile();
	// Start parser
	yyparse();
	arrayIRGen();
	arrayGen();
	IRfloatGen();
	floatGen();


	// Add the closing part required for any MIPS file
	emitEndOfInitIRCode();
	emitEndOfIRCode();
	emitEndOfInitAssemblyCode();
	emitEndOfAssemblyCode();
	appendIRFiles();
	appendFiles();

}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}