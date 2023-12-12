// Set of functions to emit MIPS code
FILE * MIPScode;
FILE * MIPSInitCode;
int registerUsed[7];
int currentRg = 0;
int currentMDMsg = 0;
int currentASMsg = 0;
char funcs[50];
int arrySize[3];
int fCnt = 0;
int arryCnt = 0;
int ifCnt = 0;
int whileCnt = 0;
int whileType = 0;
char whileID1[20];
char whileOp[2];
char whileInt[20];
char whileID2[20];

struct VarRg{
    char variable[50];
};

struct VarRg variableReg[7];
struct VarRg arry[3];
struct VarRg arryNum[3];
struct VarRg floats[5];
struct VarRg floatNum[5];
struct VarRg mDMsgs[10];
struct VarRg aSMsgs[10];

void  initAssemblyFile(){
    // Creates a MIPS file with a generic header that needs to be in every file

    MIPSInitCode = fopen("MIPSMain.asm", "a");
    MIPScode = fopen("MIPScode.asm", "a");

    while(currentRg < 6){
    registerUsed[currentRg] = 0;
    currentRg++;
    }

    while(currentMDMsg < 9){
    sprintf(mDMsgs[currentMDMsg].variable, "");
    currentMDMsg++;
    }
    currentMDMsg = 0;

    while(currentASMsg < 9){
    sprintf(aSMsgs[currentASMsg].variable, "");
    currentASMsg++;
    }
    currentASMsg = 0;
    
    fprintf(MIPSInitCode, ".data\nnewline: .asciiz \"\\n\"\n");
}

void arrayCount(const char * id, const char * count){
    sprintf(arry[arryCnt].variable, "%s", id); 
    sprintf(arryNum[arryCnt].variable, "%s", count);
    int length = atoi(count);
    arrySize[arryCnt] = length/4;
    fprintf(MIPScode, "la $s%d, %s\n", arryCnt, arry[arryCnt].variable);
    arryCnt++;
}

void arrayGen(){
    int num = 0;
    fprintf(MIPSInitCode, ".align 2\n");
    while(num < arryCnt){
        fprintf(MIPSInitCode, "%s: .space %s\n", arry[num].variable, arryNum[num].variable);
        num++;
    }
}

void floatCount(const char * id, const char * num){
    sprintf(floats[fCnt].variable, "%s", id);
    sprintf(floatNum[fCnt].variable, "%s", num);
    fprintf(MIPScode, "lwc1 $f%d, %s\n", fCnt, floats[fCnt].variable);
    fCnt++;
}

void floatGen(){
    int num = 0;
    while(num < fCnt){
        fprintf(MIPSInitCode, "%s: .float %s\n", floats[num].variable, floatNum[num].variable);
        num++;
    }
}

void MIPSIDINTIf(const char * id, const char * op, const char * num){
    currentRg = 0;

    if(strcmp(op, "<") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                currentRg = 7;
                fprintf(MIPScode, "li $t8, %s\n", num);
                fprintf(MIPScode, "slt $at, $t%d, $t8\n", currentRg);
                fprintf(MIPScode, "beq $at, $zero, if%d\n", ifCnt);
                break;
            }
            currentRg++;
        }
    }

    if(strcmp(op, ">") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                currentRg = 7;
                fprintf(MIPScode, "li $t8, %s\n", num);
                fprintf(MIPScode, "slt $at, $t8, $t%d\n", currentRg);
                fprintf(MIPScode, "beq $at, $zero, if%d\n", ifCnt);
                break;
            }
            currentRg++;
        }
    }

    if(strcmp(op, "==") == 0){
        while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id) == 0){
            //fprintf(MIPScode, "mult $t7, $t%d, %s\n", currentRg, id2);
            currentRg = 7;
            fprintf(MIPScode, "li $t8, %s\n", num);
            fprintf(MIPScode, "bne $t8, $t%d, if%d\n", currentRg, ifCnt);
            break;
            }
            currentRg++;
        }
    }
}

void MIPSIDIDWhile(const char * id, const char * op, const char * id2){
    strcpy(whileID1, id);
    strcpy(whileOp, op);
    strcpy(whileID2, id2);

    whileType = 2;

    int firstID = 0;
    currentRg = 0;
    if(strcmp(op, "<") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "slt $at, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "beq $at, $zero, whileEnd%d\n", whileCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }

    if(strcmp(op, ">") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "slt $at, $t%d, $t%d\n", currentRg, firstID);
                        fprintf(MIPScode, "beq $at, $zero, whileEnd%d\n", whileCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }

    if(strcmp(op, "==") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "bne $t%d, $t%d, whileEnd%d\n", currentRg, firstID, whileCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }
    fprintf(MIPScode, "while%d:\n", whileCnt);
}

void MIPSIDINTWhile(const char * id, const char * op, const char * num){
    strcpy(whileID1, id);
    strcpy(whileOp, op);
    strcpy(whileInt, num);

    whileType = 1;

    if(strcmp(op, "<") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                fprintf(MIPScode, "li $t9, %s\n", num);
                fprintf(MIPScode, "slt $at, $t%d, $t9\n", currentRg);
                fprintf(MIPScode, "beq $at, $zero, whileEnd%d\n", whileCnt);
                currentRg = 7;
                break;
            }
            currentRg++;
        }
    }

    if(strcmp(op, ">") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                fprintf(MIPScode, "li $t9, %s\n", num);
                fprintf(MIPScode, "slt $at, $t9, $t%d\n", currentRg);
                fprintf(MIPScode, "beq $at, $zero, whileEnd%d\n", whileCnt);
                currentRg = 7;
                break;
            }
            currentRg++;
        }
    }

    if(strcmp(op, "==") == 0){
        while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id) == 0){
            //fprintf(MIPScode, "mult $t7, $t%d, %s\n", currentRg, id2);
            fprintf(MIPScode, "li $t9, %s\n", num);
            fprintf(MIPScode, "bne $t9, $t%d, whileEnd%d\n", currentRg, whileCnt);
            currentRg = 7;
            break;
            }
            currentRg++;
        }
    }

    fprintf(MIPScode, "while%d:\n", whileCnt);
}

void MIPSEndWhile(){
    const char id[20];
    const char id2[20];
    const char op[3]; 
    const char num[20];

    strcpy(id, whileID1);
    strcpy(id2, whileID2);
    strcpy(op, whileOp);
    strcpy(num, whileInt);

    switch(whileType){
        case 1:            
            if(strcmp(op, "<") == 0)
            {
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                        fprintf(MIPScode, "li $t9, %s\n", num);
                        fprintf(MIPScode, "slt $at, $t%d, $t9\n", currentRg);
                        fprintf(MIPScode, "bne $at, $zero, while%d\n", whileCnt);
                        currentRg = 7;
                        break;
                    }
                    currentRg++;
                }
            }

            if(strcmp(op, ">") == 0)
            {
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                        fprintf(MIPScode, "li $t9, %s\n", num);
                        fprintf(MIPScode, "slt $at, $t9, $t%d\n", currentRg);
                        fprintf(MIPScode, "bne $at, $zero, while%d\n", whileCnt);
                        currentRg = 7;
                        break;
                    }
                    currentRg++;
                }
            }

            if(strcmp(op, "==") == 0){
                while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id) == 0){
                    //fprintf(MIPScode, "mult $t7, $t%d, %s\n", currentRg, id2);
                    fprintf(MIPScode, "li $t9, %s\n", num);
                    fprintf(MIPScode, "beq $t9, $t%d, while%d\n", currentRg, whileCnt);
                    currentRg = 7;
                    break;
                    }
                    currentRg++;
                }
            }

            break;

        case 2:
            int firstID = 0;
            currentRg = 0;
            if(strcmp(op, "<") == 0)
            {
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id) == 0){
                        firstID = currentRg;
                        currentRg = 0;
                        while(currentRg < 6){
                            if(strcmp(variableReg[currentRg].variable, id2) == 0){
                                //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                                fprintf(MIPScode, "slt $at, $t%d, $t%d\n", firstID, currentRg);
                                fprintf(MIPScode, "bne $at, $zero, while%d\n", whileCnt);
                                currentRg = firstID;
                                break;
                            }
                            currentRg++;
                        }
                        break;
                    }
                    currentRg++;
                }
                
            }

            if(strcmp(op, ">") == 0)
            {
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id) == 0){
                        firstID = currentRg;
                        currentRg = 0;
                        while(currentRg < 6){
                            if(strcmp(variableReg[currentRg].variable, id2) == 0){
                                //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                                fprintf(MIPScode, "slt $at, $t%d, $t%d\n", currentRg, firstID);
                                fprintf(MIPScode, "bne $at, $zero, while%d\n", whileCnt);
                                currentRg = firstID;
                                break;
                            }
                            currentRg++;
                        }
                        break;
                    }
                    currentRg++;
                }
                
            }

            if(strcmp(op, "==") == 0)
            {
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id) == 0){
                        firstID = currentRg;
                        currentRg = 0;
                        while(currentRg < 6){
                            if(strcmp(variableReg[currentRg].variable, id2) == 0){
                                //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                                fprintf(MIPScode, "beq $t%d, $t%d, while%d\n", currentRg, firstID, whileCnt);
                                currentRg = firstID;
                                break;
                            }
                            currentRg++;
                        }
                        break;
                    }
                    currentRg++;
                }
                
            }
            break;
    }

    fprintf(MIPScode, "whileEnd%d:\n", whileCnt);
    whileCnt++;
    whileType = 0;
}

void MIPSIDIDIf(const char * id, const char * op, const char * id2){
    int firstID = 0;
    currentRg = 0;
    if(strcmp(op, "<") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "slt $at, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "beq $at, $zero, if%d\n", ifCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }

    if(strcmp(op, ">") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "slt $at, $t%d, $t%d\n", currentRg, firstID);
                        fprintf(MIPScode, "beq $at, $zero, if%d\n", ifCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }

    if(strcmp(op, "==") == 0)
    {
        while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id) == 0){
                firstID = currentRg;
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                        fprintf(MIPScode, "bne $t%d, $t%d, if%d\n", currentRg, firstID, ifCnt);
                        currentRg = firstID;
                        break;
                    }
                    currentRg++;
                }
                break;
            }
            currentRg++;
        }
        
    }
}

void MIPSEndIf(){
    fprintf(MIPScode, "if%d:\n", ifCnt);
    ifCnt++;
}

// Function for MIPS code for adding ID plus NUMBER
void emitMIPSIDNumOperation(char op[1], const char* id1, const char* id2){
    currentRg = 0;
    switch(op[0]){
        case '+':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
                //fprintf(MIPScode, "add $t7, $t%d, %s\n", currentRg, id2);
                sprintf(aSMsgs[currentASMsg].variable, "add $t7, $t%d, %s\n", currentRg, id2);
                currentASMsg++;
                currentRg++;
                break;
            }
            currentRg++;
        }
        break;

        case '-':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
                //fprintf(MIPScode, "sub $t7, $t%d, %s\n", currentRg, id2);
                sprintf(aSMsgs[currentASMsg].variable, "sub $t7, $t%d, %s\n", currentRg, id2);
                currentASMsg++;
                currentRg++;
                break;
            }
            currentRg++;
        }
        break;

        case '*':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
                //fprintf(MIPScode, "mult $t7, $t%d, %s\n", currentRg, id2);
                sprintf(mDMsgs[currentMDMsg].variable, "mult $t7, $t%d, %s\n", currentRg, id2);
                currentMDMsg++;
                currentRg++;
                break;
            }
            currentRg++;
        }
        break;
        
        case '/':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
                //fprintf(MIPScode, "div $t7, $t%d, %s\n", currentRg, id2);
                sprintf(mDMsgs[currentMDMsg].variable, "div $t7, $t%d, %s\n", currentRg, id2);
                currentMDMsg++;
                currentRg++;
                break;
            }
            currentRg++;
        }

        break;
    }

}
// Function for MIPS code for adding NUMBER plus ID
void emitMIPSNumIDOperation(char op[1], const char* id1, const char* id2){
    currentRg = 0;
    switch (op[0]){
        case '+':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id2) == 0){
            //fprintf(MIPScode, "add $t7, %s, $t%d\n", id1, currentRg);
            sprintf(aSMsgs[currentASMsg].variable, "add $t7, %s, $t%d\n", id1, currentRg);
            currentASMsg++;
            currentRg++;
            break;
            }
            currentRg++;
        }
        break;

        case '-':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id2) == 0){
            //fprintf(MIPScode, "sub $t7, %s, $t%d\n", id1, currentRg);
            sprintf(aSMsgs[currentASMsg].variable, "sub $t7, %s, $t%d\n", id1, currentRg);
            currentASMsg++;
            currentRg++;
            break;
            }
            currentRg++;
        }
        break;

        case '*':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id2) == 0){
            //fprintf(MIPScode, "mult $t7, %s, $t%d\n", id1, currentRg);
            sprintf(mDMsgs[currentMDMsg].variable, "mult $t7, %s, $t%d\n", id1, currentRg);
            currentMDMsg++;
            currentRg++;
            break;
            }
            currentRg++;
        }
        break;

        case '/':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id2) == 0){
            //fprintf(MIPScode, "div $t7, %s, $t%d\n", id1, currentRg);
            sprintf(mDMsgs[currentMDMsg].variable, "div $t7, %s, $t%d\n", id1, currentRg);
            currentMDMsg++;
            currentRg++;
            break;
            }
            currentRg++;
        }
        break;
    }

}

// Function for MIPS code for adding ID plus ID
void emitMIPSIDIDOperation(char op[1], const char* id1, const char* id2){
    int firstID = 0;
    currentRg = 0;
    switch (op[0]){
        case '+':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
            firstID = currentRg;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                    sprintf(aSMsgs[currentASMsg].variable, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                    currentASMsg++;
                    currentRg = firstID;
                    break;
                }
                currentRg++;
            }
            break;
        }
        currentRg++;
    }
    break;      

        case '-':
            while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            firstID = currentRg;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    //fprintf(MIPScode, "sub $t7, $t%d, $t%d\n", firstID, currentRg);
                    sprintf(aSMsgs[currentASMsg].variable, "sub $t7, $t%d, $t%d\n", firstID, currentRg);
                    currentASMsg++;
                    currentRg = firstID;
                    break;
                }
                currentRg++;
            }
            break;
        }
        currentRg++;
    }
    break;

        case '*':
            while(currentRg < 6){
            if(strcmp(variableReg[currentRg].variable, id1) == 0){
            firstID = currentRg;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    //fprintf(MIPScode, "mult $t7, $t%d, $t%d\n", firstID, currentRg);
                    sprintf(mDMsgs[currentMDMsg].variable, "mult $t7, $t%d, $t%d\n", firstID, currentRg);
                    currentMDMsg++;
                    currentRg = firstID;
                    break;
                }
                currentRg++;
            }
            break;
        }
        currentRg++;
    }
    break;

        case '/':
            while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            firstID = currentRg;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    //fprintf(MIPScode, "div $t7, $t%d, $t%d\n", firstID, currentRg);
                    sprintf(mDMsgs[currentMDMsg].variable, "div $t7, $t%d, $t%d\n", firstID, currentRg);
                    currentMDMsg++;
                    currentRg = firstID;
                    break;
                }
                currentRg++;
            }
            break;
            }
            currentRg++;
        }      
        break;
    }
    
}

// This function is used to emit the MIPS code for assigning a register to an NUMBER PLUS NUMBER and INTEGER PLUS INTEGER
void emitMIPSBinaryOperation(char op[1], const char* id1, const char* id2){
    switch (op[0]){
        case '+':
            //fprintf(MIPScode, "addi $t7, $zero, %s \n", id1);
            //fprintf(MIPScode, "add $t7, $t7, %s\n", id2);  
            sprintf(aSMsgs[currentASMsg].variable, "addi $t7, $zero, %s \n", id1);
            currentASMsg++;
            sprintf(aSMsgs[currentASMsg].variable, "add $t7, $t7, %s\n", id2);
            currentASMsg++;
        break;

        case '-':
            //fprintf(MIPScode, "subi $t7, $zero, %s \n", id1);
            //fprintf(MIPScode, "sub $t7, $t7, %s\n", id2);  
            sprintf(aSMsgs[currentASMsg].variable, "subi $t7, $zero, %s \n", id1);
            currentASMsg++;
            sprintf(aSMsgs[currentASMsg].variable, "sub $t7, $t7, %s\n", id2);
            currentASMsg++;
        break;

        case '*':
            //fprintf(MIPScode, "multi $t7, 1, %s \n", id1);
            //fprintf(MIPScode, "mult $t7, $t7, %s\n", id2);  
            sprintf(mDMsgs[currentMDMsg].variable, "multi $t7, 1, %s \n", id1);
            currentMDMsg++;
            sprintf(mDMsgs[currentMDMsg].variable, "mult $t7, $t7, %s\n", id2);
            currentMDMsg++;
        break;

        case '/':
            //fprintf(MIPScode, "divi $t7, 1, %s \n", id1);
            //fprintf(MIPScode, "div $t7, $t7, %s\n", id2);  
            sprintf(mDMsgs[currentMDMsg].variable, "divi $t7, 1, %s \n", id1);
            currentMDMsg++;
            sprintf(mDMsgs[currentMDMsg].variable, "div $t7, $t7, %s\n", id2);
            currentMDMsg++;
        break;
    }

}

// This function is used to emit the MIPS code for adding a register to a NUMBER PLUS ID
void emitMIPSNumIDBinaryOperation(char op[1], const char* id1, const char* id2){
    currentRg = 0;
    switch(op[0]){
        case '+':
            //fprintf(MIPScode, "addi $t7, $zero, %s \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "addi $t7, $zero, %s \n", id1);
            currentASMsg++;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                //fprintf(MIPScode, "add $t7, $t7, $t%d\n", currentRg);
                sprintf(aSMsgs[currentASMsg].variable, "add $t7, $t7, $t%d\n", currentRg);
                currentASMsg++;
                break;
            }
            currentRg++;
        }
        break;

        case '-':
            //fprintf(MIPScode, "subi $t7, $zero, %s \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "subi $t7, $zero, %s \n", id1);
            currentASMsg++;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                //fprintf(MIPScode, "sub $t7, $t7, $t%d\n", currentRg);
                sprintf(aSMsgs[currentASMsg].variable, "sub $t7, $t7, $t%d\n", currentRg);
                currentASMsg++;
                break;
            }
            currentRg++;
        }
        break;

        case '*':
            //fprintf(MIPScode, "multi $t7, 1, %s \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "multi $t7, 1, %s \n", id1);
            currentASMsg++;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                //fprintf(MIPScode, "mult $t7, $t7, $t%d\n", currentRg);
                sprintf(mDMsgs[currentMDMsg].variable, "mult $t7, $t7, $t%d\n", currentRg);
                currentMDMsg++;
                break;
            }
            currentRg++;
        }
        break;

        case '/':
            //fprintf(MIPScode, "divi $t7, 1, %s \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "divi $t7, 1, %s \n", id1);
            currentASMsg++;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                //fprintf(MIPScode, "div $t7, $t7, $t%d\n", currentRg);
                sprintf(mDMsgs[currentMDMsg].variable, "div $t7, $t7, $t%d\n", currentRg);
                currentMDMsg++;
                break;
            }
            currentRg++;
        }
        break;
    }      

}
// Function for adding an ID plus ARITH (Long expression that recursively calls itself)
void emitMIPSBinaryOperationArith(char op[1], const char* id1){
    currentRg = 0;
    
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            switch (op[0]){
        case '+':
            //fprintf(MIPScode, "addi $t7, $t%d, $t7 \n", currentRg);
            sprintf(aSMsgs[currentASMsg].variable, "addi $t7, $t%d, $t7 \n", currentRg);
            currentASMsg++;
        break;

        case '-':
            //fprintf(MIPScode, "subi $t7, $t%d, $t7 \n", currentRg);
            sprintf(aSMsgs[currentASMsg].variable, "subi $t7, $t%d, $t7 \n", currentRg);
            currentASMsg++;
        break;

        case '*':
            //fprintf(MIPScode, "multi $t7, $t%d, $t7 \n", currentRg); 
            sprintf(mDMsgs[currentMDMsg].variable, "multi $t7, $t%d, $t7 \n", currentRg);
            currentMDMsg++;
        break;

        case '/':
            //fprintf(MIPScode, "divi $t7, $t%d, $t7 \n", currentRg);
            sprintf(mDMsgs[currentMDMsg].variable, "divi $t7, $t%d, $t7 \n", currentRg);
            currentMDMsg++;
        break;
    }
        }
        currentRg++;
    }      
}

// Function for adding an NUMBER plus ARITH (Long expression that recursively calls itself)
void emitMIPSNumBinaryOperationArith(char op[1], const char* id1){
    switch (op[0]){
        case '+':
            //fprintf(MIPScode, "addi $t7, %s, $t7 \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "addi $t7, %s, $t7 \n", id1);
            currentASMsg++;
        break;

        case '-':
            //fprintf(MIPScode, "subi $t7, %s, $t7 \n", id1);
            sprintf(aSMsgs[currentASMsg].variable, "subi $t7, %s, $t7 \n", id1);
            currentASMsg++;
        break;

        case '*':
            //fprintf(MIPScode, "multi $t7, %s, $t7 \n", id1); 
            sprintf(mDMsgs[currentMDMsg].variable, "multi $t7, %s, $t7 \n", id1);
            currentMDMsg++;
        break;

        case '/':
            //fprintf(MIPScode, "divi $t7, %s, $t7 \n", id1);
            sprintf(mDMsgs[currentMDMsg].variable, "divi $t7, %s, $t7 \n", id1);
            currentMDMsg++;
        break;
    }
}

// This function is used to emit the MIPS code for an emit assignment for ARITH where we load the output of a function into the last register
// For instance z = x + y... would need emitArithAssignment for z
void emitMIPSArithAssignment (char id1[50]){
    int exists = 0;
    currentRg = 0;
    
    printMessages();

    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            fprintf(MIPScode, "move $t%d, $t7\n", currentRg);
            exists = 1;
            break;
        }
        currentRg++;
    }
    if(exists != 1){
        currentRg = 0;
        while(currentRg < 6){
            if(registerUsed[currentRg] == 0){
                fprintf(MIPScode, "move $t%d, $t7\n", currentRg);
                //fprintf(MIPScode, "%s = ASSIGN T%d\n", id1, currentRg);
                registerUsed[currentRg] = 1;
                strcpy(variableReg[currentRg].variable, id1);
                break;
            }
            if(currentRg == 6){
                fprintf(MIPScode, "\nERROR: No registers available.");
                break;
            }
            currentRg++;
        }
    }
    
}
// This function is used to emit MIPS Code assignment statements for ID = ID.
// Works the same as emitArithAssignment but does not use the last register instead the next available register.
void emitMIPSAssignment(char * id1, char * id2){
  // This is the temporary approach, until register management is implemented
    int exists = 0;
    int firstID = 0;
    currentRg = 0;
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            firstID = currentRg;
            exists = 1;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    fprintf(MIPScode, "move $t%d, $t%d\n", firstID, currentRg);
                    currentRg = firstID;
                    break;
                }
                currentRg++;
            }
            break;
        }
        currentRg++;
    }
    if(exists != 1){
        currentRg = 0;
        while(currentRg < 6){
            if(registerUsed[currentRg] == 0){
                registerUsed[currentRg] = 1;
                firstID = currentRg;
                strcpy(variableReg[currentRg].variable, id1);
                currentRg = 0;
                while(currentRg < 6){
                    if(strcmp(variableReg[currentRg].variable, id2) == 0){
                        fprintf(MIPScode, "move $t%d, $t%d\n", firstID, currentRg);
                        //fprintf(MIPScode, "%s = ASSIGN T%d\n", id1, firstID);
                        break;
                    }
                    currentRg++;
                }                
                break;
            }
            if(currentRg == 6){
                fprintf(MIPScode, "\nERROR: No registers available.");
                break;
            }
            currentRg++;
        }
    }
}
// This function is used to emit MIPS code for assignment statements for ID = Number.
// Works the same as emitArithAssignment but does not use the last register instead the next available register.
void emitMIPSConstantIntAssignment (char id1[50], char id2[50]){
    int exists = 0;
    currentRg = 0;
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id1) == 0){
            fprintf(MIPScode, "li $t%d, %s\n", currentRg, id2);
            exists = 1;
            break;
        }
        currentRg++;
    }
    if(exists != 1){
        currentRg = 0;
        while(currentRg < 6){
            if(registerUsed[currentRg] == 0){
                fprintf(MIPScode, "li $t%d, %s\n", currentRg, id2);
                //fprintf(MIPScode, "%s = ASSIGN T%d\n", id1, currentRg);
                registerUsed[currentRg] = 1;
                strcpy(variableReg[currentRg].variable, id1);
                break;
            }
            if(currentRg == 6){
                fprintf(MIPScode, "\nERROR: No registers available.");
                break;
            }
            currentRg++;
        }
    }
}

void emitMIPSConstantFlAssignment (char id1[50], char id2[50]){
    currentRg = 0;
    while(currentRg < 4){
        if(strcmp(floats[currentRg].variable, id1) == 0){
            fprintf(MIPScode, "swc1 $f%d, %s\n", currentRg, floats[currentRg].variable);
            break;
        }
        currentRg++;
    }    
}

void emitMIPSArrayAssignmentID(char id1[50], int index, char id2[50]){
    currentRg = 0;
    int first;
    while(currentRg < 2){
        if(strcmp(arry[currentRg].variable, id1) == 0 && index < arrySize[currentRg]){
            first = currentRg;
            currentRg = 0;
            while(currentRg < 6){
                if(strcmp(variableReg[currentRg].variable, id2) == 0){
                    //fprintf(MIPScode, "add $t7, $t%d, $t%d\n", firstID, currentRg);
                    fprintf(MIPScode, "move $t7, $t%d\n", currentRg);
                    fprintf(MIPScode, "li $t8, %d\n", index);
                    fprintf(MIPScode, "mul $t8, $t8, 4\n");
                    fprintf(MIPScode, "add $t8, $t8, $s%d\n", first);
                    fprintf(MIPScode, "sw $t7, 0($t8)\n");
                    currentASMsg++;
                    currentRg = first;
                    break;
                }
                currentRg++;
            }
            break;
        }
        currentRg++;
    }
}

void emitMIPSArrayAssignmentConst(char id1[50], int index, char id2[50]) {
    currentRg = 0;
    while(currentRg < 2){
        if(strcmp(arry[currentRg].variable, id1) == 0 && index < arrySize[currentRg]){
            fprintf(MIPScode, "li $t7, %s\n", id2);
            fprintf(MIPScode, "li $t8, %d\n", index);
            fprintf(MIPScode, "mul $t8, $t8, 4\n");
            fprintf(MIPScode, "add $t8, $t8, $s%d\n", currentRg);
            fprintf(MIPScode, "sw $t7, 0($t8)\n");
            break;
        }
        currentRg++;
    }
}

void functionDeclarationMIPS(char * id){
    fprintf(MIPScode, "\nj end%s\n", id);
    fprintf(MIPScode, "%s:\n", id);
    strcpy(funcs, id);
}

void returnMIPS(char * id){
    currentRg = 0;
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id) == 0){
            //fprintf(MIPScode, "add $t7, %s, $t%d\n", id1, currentRg);
            fprintf(MIPScode, "add $t7, $zero, $t%d \n", currentRg);
            break;
        }
        currentRg++;
    }
    fprintf(MIPScode, "\nj call%s\n", funcs);
    fprintf(MIPScode, "end%s:\n", funcs);
}

void MIPSIDFuncAssignment(char * id, char * func){
    fprintf(MIPScode, "\nj %s", func);
    fprintf(MIPScode, "\ncall%s:\n", funcs);
    currentRg = 0;
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id) == 0){
            fprintf(MIPScode, "move $t%d, $t7\n", currentRg);
            break;
        }
        currentRg++;
    }
}

void emitMIPSWriteId(char * id){
    int exists = 0;
    currentRg = 0;
    while(currentRg < 6){
        if(strcmp(variableReg[currentRg].variable, id) == 0){
            fprintf(MIPScode, "\nli $v0, 1\nmove $a0, $t%d\nsyscall\n\n", currentRg);
            fprintf(MIPScode, "li $v0, 4\nla $a0, newline\nsyscall\n\n");
            exists = 1;
            break;
        }
        currentRg++;
    }
}

void printMessages(){

    for (int i = 0; i < currentMDMsg; i++) {
        if (mDMsgs[i].variable[0] != '\0') {
            fprintf(MIPScode, "%s", mDMsgs[i].variable);
            mDMsgs[i].variable[0] = '\0';  // Clear the array element after printing
        }
    }
    for (int i = 0; i < currentASMsg; i++) {
        if (aSMsgs[i].variable[0] != '\0') {
            fprintf(MIPScode, "%s", aSMsgs[i].variable);
            aSMsgs[i].variable[0] = '\0';  // Clear the array element after printing
        }
    }
    currentMDMsg = 0;
    currentASMsg = 0;
}

void emitEndOfAssemblyCode(){
    fprintf(MIPScode, "# -----------------\n");
    fprintf(MIPScode, "#  Done, terminate program.\n\n");
    fprintf(MIPScode, "li $v0,10   # call code for terminate\n");
    fprintf(MIPScode, "syscall      # system call (terminate)\n");
    fprintf(MIPScode, ".end main\n");
    fclose(MIPScode);
}

void emitEndOfInitAssemblyCode(){
    fprintf(MIPSInitCode, ".text\n");
    fprintf(MIPSInitCode, "main:\n");
    fprintf(MIPSInitCode, "# -----------------------\n");
    fclose(MIPSInitCode);
}

#include <stdio.h>

void appendFiles() {
    FILE *MIPScode;
    FILE *MIPSInitCode;

    // Open the source file (MIPScode.asm) for reading
    MIPScode = fopen("MIPScode.asm", "r");

    if (MIPScode == NULL) {
        fprintf(stderr, "Error opening MIPScode.asm for reading.\n");
        return;
    }

    // Open the destination file (MIPSinit.asm) for appending
    MIPSInitCode = fopen("MIPSMain.asm", "a");

    if (MIPSInitCode == NULL) {
        fprintf(stderr, "Error opening MIPSinit.asm for appending.\n");
        fclose(MIPScode);  // Close the source file
        return;
    }

    char ch;

    // Read and write each character from the source file (MIPScode.asm) to the destination file (MIPSinit.asm)
    while ((ch = fgetc(MIPScode)) != EOF) {
        fputc(ch, MIPSInitCode);
    }

    // Close the files
    fclose(MIPScode);
    fclose(MIPSInitCode);
}
