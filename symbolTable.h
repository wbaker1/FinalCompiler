
//Symbol table header
#include <string.h>

struct Entry
{
	int itemID;
	char itemName[50];  //the name of the identifier
	char itemKind[8];  //is it a function or a variable?
	char itemType[8];  // Is it int, char, etc.?
	int arrayLength;
	char scope[50];     // global, or the name of the function
};

struct Entry symTabItems[100];
int symTabIndex = 0;
int SYMTAB_SIZE = 20;

void symTabAccess(void){
	printf("::::> Symbol table accessed.\n");
}

void addItem(char itemName[50], char itemKind[8], char itemType[8], int arrayLength, char scope[50]){
	

		// what about scope? should you add scope to this function?
		symTabItems[symTabIndex].itemID = symTabIndex;
		strcpy(symTabItems[symTabIndex].itemName, itemName);
		strcpy(symTabItems[symTabIndex].itemKind, itemKind);
		strcpy(symTabItems[symTabIndex].itemType, itemType);
		symTabItems[symTabIndex].arrayLength = arrayLength;
		strcpy(symTabItems[symTabIndex].scope, scope);
		symTabIndex++;
	
}

void showSymTable(){
	printf("itemID    itemName    itemKind    itemType     ArrayLength    itemScope\n");
	printf("-----------------------------------------------------------------------\n");
	for (int i=0; i<symTabIndex; i++){
		printf("%5d %15s  %7s  %7s %6d %15s \n",symTabItems[i].itemID, symTabItems[i].itemName, symTabItems[i].itemKind, symTabItems[i].itemType, symTabItems[i].arrayLength, "global");
	}
	

	printf("-----------------------------------------------------------------------\n");
}

int found(char itemName[50], char scope[50]) {
    for (int i = 0; i < symTabIndex; i++) {
        int str1 = strcmp(symTabItems[i].itemName, itemName);
        int str2 = strcmp(symTabItems[i].scope, scope);
        if (str1 == 0 && str2 == 0) {
            return 1; // found the ID in the table
        }
    }
    return 0;
}


const char* getVariableType(char itemName[50], char scope[50]){
	//char *name = "int";
	//return name;

	for(int i=0; i<SYMTAB_SIZE; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope,scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			return symTabItems[i].itemType; // found the ID in the table
		}
	}
	return NULL;
}

int compareTypes(char itemName1[50], char itemName2[50],char scope[50]){
	const char* idType1 = getVariableType(itemName1, scope);
	const char* idType2 = getVariableType(itemName2, scope);
	
	printf("%s = %s\n", idType1, idType2);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		return 1; // types are matching
	}
	else return 0;
}

int compareTypeInts(char itemName1[50], int itemName2[50],char scope[50]){
	const char* idType1 = getVariableType(itemName1, scope);
	const char* idType2 = "int";
	
	printf("%s = %s\n", idType1, idType2);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		return 1; // types are matching
	}
	else return 0;
}

int compareTypeChars(char itemName1[50], char itemName2[50],char scope[50]){
	const char* idType1 = getVariableType(itemName1, scope);
	const char* idType2 = "char";
	
	printf("%s = %s\n", idType1, idType2);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		return 1; // types are matching
	}
	else return 0;
}

int compareTypeFloats(char itemName1[50], float itemName2[50],char scope[50]){
	const char* idType1 = getVariableType(itemName1, scope);
	const char* idType2 = "float";
	
	printf("%s = %s\n", idType1, idType2);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		return 1; // types are matching
	}
	else return 0;
}

int withinBounds(char *arrayName, int index){
    // Find the array in your symbol table based on arrayName
    // For example, if you have a function like getSymbolTableItem(char *name)
    // you can use it to retrieve the array details

    // Assuming symTabItems is an array of struct and one of the struct fields is the name
    for(int i = 0; i < SYMTAB_SIZE; i++){
        if(strcmp(symTabItems[i].itemName, arrayName) == 0){  // Check if the name matches
            if(index < symTabItems[i].arrayLength){
				// Debug print index and arrayLength
				printf("index: %d, arrayLength: %d\n", index, symTabItems[i].arrayLength);
                return 1; // index is within bounds
            }
            else {
                return 0; // index is out of bounds
            }
        }
    }
    // If the array name is not found in symTabItems, handle the error appropriately
    printf("Array %s not found in symbol table\n", arrayName);
    return 0;
}





    