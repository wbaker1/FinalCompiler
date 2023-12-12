//Abstract Syntax Tree Implementation
#include <string.h>


struct AST{
	char nodeType[50];
	char LHS[50];
	char RHS[50];
	
	struct AST * left;
	struct AST * right;
	// review pointers to structs in C 
	// complete the tree struct with pointers
};

struct AST2{
	char nodeType[50];
	char LHS[50];
	char RHS;
	
	struct AST2 * left;
	struct AST2 * right;
	// review pointers to structs in C 
	// complete the tree struct with pointers
};

struct AST2 * AST_assignmentC(char nodeType[50], char LHS[50], char RHS){
	printf("Inside AST2 function");
	printf("%s %s %c", nodeType, LHS, RHS);
	struct AST2* ASTassign = malloc(sizeof(struct AST2));
	//print out the value of astassign after malloc
	//printf("%s %s %c", ASTassign->nodeType, ASTassign->LHS, ASTassign->RHS);
	strcpy(ASTassign->nodeType, nodeType);
	strcpy(ASTassign->LHS, LHS);
	ASTassign->RHS = RHS;
	

/*
       =
	 /   \
	x     y

*/	
	return ASTassign;
	
}

struct AST * AST_assignment(char nodeType[50], char LHS[50], char RHS[50]){
	printf("Inside AST function");
	printf("%s %s %s", nodeType, LHS, RHS);
	struct AST* ASTassign = malloc(sizeof(struct AST));
	strcpy(ASTassign->nodeType, nodeType);
	strcpy(ASTassign->LHS, LHS);
	strcpy(ASTassign->RHS, RHS);



/*
       =
	 /   \
	x     y

*/	
	return ASTassign;
	
}

struct AST * AST_IFStatement(char nodeType[50], char LHS[50], char RHS[50]){
	printf("Inside AST function");
	printf("%s %s %s", nodeType, LHS, RHS);
	struct AST* ASTassign = malloc(sizeof(struct AST));
	strcpy(ASTassign->nodeType, nodeType);
	strcpy(ASTassign->LHS, LHS);
	strcpy(ASTassign->RHS, RHS);



/*
       =
	 /   \
	x     y

*/	
	return ASTassign;
	
}

struct AST * AST_BinaryExpression(char nodeType[50], char LHS[50], char RHS[50]){

	struct AST* ASTBinExp = malloc(sizeof(struct AST));
	strcpy(ASTBinExp->nodeType, nodeType);
	strcpy(ASTBinExp->LHS, LHS);
	strcpy(ASTBinExp->RHS, RHS);
	return ASTBinExp;
	
}
struct AST * AST_Type(char nodeType[50], char LHS[50], char RHS[50]){

	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

struct AST * AST_Func(char nodeType[50], char LHS[50], char RHS[50]){
	
	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

struct AST * AST_Write(char nodeType[50], char LHS[50], char RHS[50]){
	
	struct AST* ASTtype = malloc(sizeof(struct AST));
	strcpy(ASTtype->nodeType, nodeType);
	strcpy(ASTtype->LHS, LHS);
	strcpy(ASTtype->RHS, RHS);  // This line has a typo, it should be strcpy(ASTtype->RHS, RHS);
		
	return ASTtype;
	
}

void printDots(int num)
{
	for (int i = 0; i < num; i++)
		printf("      ");
}

void printAST(struct AST* tree, int level) {
    if (tree == NULL) return;
    printDots(level);
    printf("%s\n", tree->nodeType);
    printDots(level);
    printf("%s %s\n", tree->LHS, tree->RHS);
    if (tree->left != NULL) printAST(tree->left, level + 1);
    if (tree->right != NULL) printAST(tree->right, level + 1);
}
/*
struct AST* AST_IfThen(char nodeType[50], char condition[50], struct AST* thenBranch) {
    struct AST* ifThenNode = malloc(sizeof(struct AST));
    strcpy(ifThenNode->nodeType, nodeType);
    strcpy(ifThenNode->condition, condition);
    ifThenNode->thenBranch = thenBranch;
    ifThenNode->elseBranch = NULL;
    return ifThenNode;
}

struct AST* AST_IfThenElse(char nodeType[50], char condition[50], struct AST* thenBranch, struct AST* elseBranch) {
    struct AST* ifThenElseNode = malloc(sizeof(struct AST));
    strcpy(ifThenElseNode->nodeType, nodeType);
    strcpy(ifThenElseNode->condition, condition);
    ifThenElseNode->thenBranch = thenBranch;
    ifThenElseNode->elseBranch = elseBranch;
    return ifThenElseNode;
}

struct AST* AST_IfThenIfThenElse(char nodeType[50], char condition[50], struct AST* thenBranch1, struct AST* thenBranch2, struct AST* elseBranch) {
    struct AST* ifThenIfThenElseNode = malloc(sizeof(struct AST));
    strcpy(ifThenIfThenElseNode->nodeType, nodeType);
    strcpy(ifThenIfThenElseNode->condition, condition);
    ifThenIfThenElseNode->thenBranch = AST_IfThen(nodeType, condition, thenBranch1);
    ifThenIfThenElseNode->elseBranch = elseBranch;
    thenBranch1->elseBranch = AST_IfThen(nodeType, condition, thenBranch2);
    return ifThenIfThenElseNode;
}
*/
























