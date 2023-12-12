// Set of functions to emit IR code
FILE * IRcode;
FILE * IRInitCode;
int IRregisterUsed[7];
int IRcurrentRg = 0;
int IRcurrentMDMsg = 0;
int IRcurrentASMsg = 0;
char IRfuncs[50];
int IrarrySize[3];
int IRfCnt = 0;
int IRIrarryCnt = 0;
int IRiIRfCnt = 0;
int IRwhileCnt = 0;
int IRwhileType = 0;
char IRwhileID1[20];
char whileOp[2];
char IRwhileInt[20];
char IRwhileID2[20];

struct IRVarRg{
    char Irvariable[50];
};

struct IRVarRg IRIrvariableReg[7];
struct IRVarRg Irarry[3];
struct IRVarRg IrIRarryNum[3];
struct IRVarRg Irfloats[5];
struct IRVarRg IRfloatNum[5];
struct IRVarRg IRmDMsgs[10];
struct IRVarRg IRaSMsgs[10];

void  initIRFile(){
    // Creates a IR file with a generic header that needs to be in every file

    IRInitCode = fopen("IRMain.ir", "a");
    IRcode = fopen("IRcode.ir", "a");

    while(IRcurrentRg < 6){
    IRregisterUsed[IRcurrentRg] = 0;
    IRcurrentRg++;
    }

    while(IRcurrentMDMsg < 9){
    sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "");
    IRcurrentMDMsg++;
    }
    IRcurrentMDMsg = 0;

    while(IRcurrentASMsg < 9){
    sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "");
    IRcurrentASMsg++;
    }
    IRcurrentASMsg = 0;
    
    fprintf(IRInitCode, ".data\nnewline: .asciiz \"\\n\"\n");
}

void arrayIRCount(const char * id, const char * count){
    sprintf(Irarry[IRIrarryCnt].Irvariable, "%s", id); 
    sprintf(IrIRarryNum[IRIrarryCnt].Irvariable, "%s", count);
    int length = atoi(count);
    IrarrySize[IRIrarryCnt] = length/4;
    fprintf(IRcode, "LOADADDRESS $s%d, %s\n", IRIrarryCnt, Irarry[IRIrarryCnt].Irvariable);
    IRIrarryCnt++;
}

void arrayIRGen(){
    int num = 0;
    fprintf(IRInitCode, ".align 2\n");
    while(num < IRIrarryCnt){
        fprintf(IRInitCode, "%s: .space %s\n", Irarry[num].Irvariable, IrIRarryNum[num].Irvariable);
        num++;
    }
}

void IRfloatCount(const char * id, const char * num){
    sprintf(Irfloats[IRfCnt].Irvariable, "%s", id);
    sprintf(IRfloatNum[IRfCnt].Irvariable, "%s", num);
    fprintf(IRcode, "LOADWORD $f%d, %s\n", IRfCnt, Irfloats[IRfCnt].Irvariable);
    IRfCnt++;
}

void IRfloatGen(){
    int num = 0;
    while(num < IRfCnt){
        fprintf(IRInitCode, "%s: .float %s\n", Irfloats[num].Irvariable, IRfloatNum[num].Irvariable);
        num++;
    }
}

void IRIDINTIf(const char * id, const char * op, const char * num){
    IRcurrentRg = 0;

    if(strcmp(op, "<") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentRg = 7;
                fprintf(IRcode, "LOADITEM $t8, %s\n", num);
                fprintf(IRcode, "LESSTHAN $at, $t%d, $t8\n", IRcurrentRg);
                fprintf(IRcode, "EQUAL $at, $zero, if%d\n", IRiIRfCnt);
                break;
            }
            IRcurrentRg++;
        }
    }

    if(strcmp(op, ">") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentRg = 7;
                fprintf(IRcode, "LOADITEM $t8, %s\n", num);
                fprintf(IRcode, "LESSTHAN $at, $t8, $t%d\n", IRcurrentRg);
                fprintf(IRcode, "EQUAL $at, $zero, if%d\n", IRiIRfCnt);
                break;
            }
            IRcurrentRg++;
        }
    }

    if(strcmp(op, "==") == 0){
        while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
            //fprintf(IRcode, "mult $t7, $t%d, %s\n", IRcurrentRg, id2);
            IRcurrentRg = 7;
            fprintf(IRcode, "LOADITEM $t8, %s\n", num);
            fprintf(IRcode, "NOTEQUAL $t8, $t%d, if%d\n", IRcurrentRg, IRiIRfCnt);
            break;
            }
            IRcurrentRg++;
        }
    }
}

void IRIDIDWhile(const char * id, const char * op, const char * id2){
    strcpy(IRwhileID1, id);
    strcpy(whileOp, op);
    strcpy(IRwhileID2, id2);

    IRwhileType = 2;

    int firstID = 0;
    IRcurrentRg = 0;
    if(strcmp(op, "<") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "EQUAL $at, $zero, whileEnd%d\n", IRwhileCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }

    if(strcmp(op, ">") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", IRcurrentRg, firstID);
                        fprintf(IRcode, "EQUAL $at, $zero, whileEnd%d\n", IRwhileCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }

    if(strcmp(op, "==") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "NOTEQUAL $t%d, $t%d, whileEnd%d\n", IRcurrentRg, firstID, IRwhileCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }
    fprintf(IRcode, "while%d:\n", IRwhileCnt);
}

void IRIDINTWhile(const char * id, const char * op, const char * num){
    strcpy(IRwhileID1, id);
    strcpy(whileOp, op);
    strcpy(IRwhileInt, num);

    IRwhileType = 1;

    if(strcmp(op, "<") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                fprintf(IRcode, "LOADITEM $t9, %s\n", num);
                fprintf(IRcode, "LESSTHAN $at, $t%d, $t9\n", IRcurrentRg);
                fprintf(IRcode, "EQUAL $at, $zero, whileEnd%d\n", IRwhileCnt);
                IRcurrentRg = 7;
                break;
            }
            IRcurrentRg++;
        }
    }

    if(strcmp(op, ">") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                fprintf(IRcode, "LOADITEM $t9, %s\n", num);
                fprintf(IRcode, "LESSTHAN $at, $t9, $t%d\n", IRcurrentRg);
                fprintf(IRcode, "EQUAL $at, $zero, whileEnd%d\n", IRwhileCnt);
                IRcurrentRg = 7;
                break;
            }
            IRcurrentRg++;
        }
    }

    if(strcmp(op, "==") == 0){
        while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
            //fprintf(IRcode, "mult $t7, $t%d, %s\n", IRcurrentRg, id2);
            fprintf(IRcode, "LOADITEM $t9, %s\n", num);
            fprintf(IRcode, "NOTEQUAL $t9, $t%d, whileEnd%d\n", IRcurrentRg, IRwhileCnt);
            IRcurrentRg = 7;
            break;
            }
            IRcurrentRg++;
        }
    }

    fprintf(IRcode, "while%d:\n", IRwhileCnt);
}

void IREndWhile(){
    const char id[20];
    const char id2[20];
    const char op[3]; 
    const char num[20];

    strcpy(id, IRwhileID1);
    strcpy(id2, IRwhileID2);
    strcpy(op, whileOp);
    strcpy(num, IRwhileInt);

    switch(IRwhileType){
        case 1:            
            if(strcmp(op, "<") == 0)
            {
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                        fprintf(IRcode, "LOADITEM $t9, %s\n", num);
                        fprintf(IRcode, "LESSTHAN $at, $t%d, $t9\n", IRcurrentRg);
                        fprintf(IRcode, "NOTEQUAL $at, $zero, while%d\n", IRwhileCnt);
                        IRcurrentRg = 7;
                        break;
                    }
                    IRcurrentRg++;
                }
            }

            if(strcmp(op, ">") == 0)
            {
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                        fprintf(IRcode, "LOADITEM $t9, %s\n", num);
                        fprintf(IRcode, "LESSTHAN $at, $t9, $t%d\n", IRcurrentRg);
                        fprintf(IRcode, "NOTEQUAL $at, $zero, while%d\n", IRwhileCnt);
                        IRcurrentRg = 7;
                        break;
                    }
                    IRcurrentRg++;
                }
            }

            if(strcmp(op, "==") == 0){
                while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                    //fprintf(IRcode, "mult $t7, $t%d, %s\n", IRcurrentRg, id2);
                    fprintf(IRcode, "LOADITEM $t9, %s\n", num);
                    fprintf(IRcode, "EQUAL $t9, $t%d, while%d\n", IRcurrentRg, IRwhileCnt);
                    IRcurrentRg = 7;
                    break;
                    }
                    IRcurrentRg++;
                }
            }

            break;

        case 2:
            int firstID = 0;
            IRcurrentRg = 0;
            if(strcmp(op, "<") == 0)
            {
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                        firstID = IRcurrentRg;
                        IRcurrentRg = 0;
                        while(IRcurrentRg < 6){
                            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                                //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                                fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", firstID, IRcurrentRg);
                                fprintf(IRcode, "NOTEQUAL $at, $zero, while%d\n", IRwhileCnt);
                                IRcurrentRg = firstID;
                                break;
                            }
                            IRcurrentRg++;
                        }
                        break;
                    }
                    IRcurrentRg++;
                }
                
            }

            if(strcmp(op, ">") == 0)
            {
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                        firstID = IRcurrentRg;
                        IRcurrentRg = 0;
                        while(IRcurrentRg < 6){
                            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                                //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                                fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", IRcurrentRg, firstID);
                                fprintf(IRcode, "NOTEQUAL $at, $zero, while%d\n", IRwhileCnt);
                                IRcurrentRg = firstID;
                                break;
                            }
                            IRcurrentRg++;
                        }
                        break;
                    }
                    IRcurrentRg++;
                }
                
            }

            if(strcmp(op, "==") == 0)
            {
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                        firstID = IRcurrentRg;
                        IRcurrentRg = 0;
                        while(IRcurrentRg < 6){
                            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                                //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                                fprintf(IRcode, "EQUAL $t%d, $t%d, while%d\n", IRcurrentRg, firstID, IRwhileCnt);
                                IRcurrentRg = firstID;
                                break;
                            }
                            IRcurrentRg++;
                        }
                        break;
                    }
                    IRcurrentRg++;
                }
                
            }
            break;
    }

    fprintf(IRcode, "whileEnd%d:\n", IRwhileCnt);
    IRwhileCnt++;
    IRwhileType = 0;
}

void IRIDIDIf(const char * id, const char * op, const char * id2){
    int firstID = 0;
    IRcurrentRg = 0;
    if(strcmp(op, "<") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "EQUAL $at, $zero, if%d\n", IRiIRfCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }

    if(strcmp(op, ">") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "LESSTHAN $at, $t%d, $t%d\n", IRcurrentRg, firstID);
                        fprintf(IRcode, "EQUAL $at, $zero, if%d\n", IRiIRfCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }

    if(strcmp(op, "==") == 0)
    {
        while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
                firstID = IRcurrentRg;
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                        fprintf(IRcode, "NOTEQUAL $t%d, $t%d, if%d\n", IRcurrentRg, firstID, IRiIRfCnt);
                        IRcurrentRg = firstID;
                        break;
                    }
                    IRcurrentRg++;
                }
                break;
            }
            IRcurrentRg++;
        }
        
    }
}

void IREndIf(){
    fprintf(IRcode, "IFEND%d\n", IRiIRfCnt);
    IRiIRfCnt++;
}

// Function for IR code for adding ID plus NUMBER
void emitIRIDNumOperation(char op[1], const char* id1, const char* id2){
    IRcurrentRg = 0;
    switch(op[0]){
        case '+':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
                //fprintf(IRcode, "add $t7, $t%d, %s\n", IRcurrentRg, id2);
                sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentASMsg++;
                IRcurrentRg++;
                break;
            }
            IRcurrentRg++;
        }
        break;

        case '-':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
                //fprintf(IRcode, "sub $t7, $t%d, %s\n", IRcurrentRg, id2);
                sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentASMsg++;
                IRcurrentRg++;
                break;
            }
            IRcurrentRg++;
        }
        break;

        case '*':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
                //fprintf(IRcode, "mult $t7, $t%d, %s\n", IRcurrentRg, id2);
                sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentMDMsg++;
                IRcurrentRg++;
                break;
            }
            IRcurrentRg++;
        }
        break;
        
        case '/':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
                //fprintf(IRcode, "div $t7, $t%d, %s\n", IRcurrentRg, id2);
                sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, $t%d, %s\n", IRcurrentRg, id2);
                IRcurrentMDMsg++;
                IRcurrentRg++;
                break;
            }
            IRcurrentRg++;
        }

        break;
    }

}
// Function for IR code for adding NUMBER plus ID
void emitIRNumIDOperation(char op[1], const char* id1, const char* id2){
    IRcurrentRg = 0;
    switch (op[0]){
        case '+':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
            //fprintf(IRcode, "add $t7, %s, $t%d\n", id1, IRcurrentRg);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, %s, $t%d\n", id1, IRcurrentRg);
            IRcurrentASMsg++;
            IRcurrentRg++;
            break;
            }
            IRcurrentRg++;
        }
        break;

        case '-':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
            //fprintf(IRcode, "sub $t7, %s, $t%d\n", id1, IRcurrentRg);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, %s, $t%d\n", id1, IRcurrentRg);
            IRcurrentASMsg++;
            IRcurrentRg++;
            break;
            }
            IRcurrentRg++;
        }
        break;

        case '*':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
            //fprintf(IRcode, "mult $t7, %s, $t%d\n", id1, IRcurrentRg);
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, %s, $t%d\n", id1, IRcurrentRg);
            IRcurrentMDMsg++;
            IRcurrentRg++;
            break;
            }
            IRcurrentRg++;
        }
        break;

        case '/':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
            //fprintf(IRcode, "div $t7, %s, $t%d\n", id1, IRcurrentRg);
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, %s, $t%d\n", id1, IRcurrentRg);
            IRcurrentMDMsg++;
            IRcurrentRg++;
            break;
            }
            IRcurrentRg++;
        }
        break;
    }

}

// Function for IR code for adding ID plus ID
void emitIRIDIDOperation(char op[1], const char* id1, const char* id2){
    int firstID = 0;
    IRcurrentRg = 0;
    switch (op[0]){
        case '+':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            firstID = IRcurrentRg;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    IRcurrentASMsg++;
                    IRcurrentRg = firstID;
                    break;
                }
                IRcurrentRg++;
            }
            break;
        }
        IRcurrentRg++;
    }
    break;      

        case '-':
            while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            firstID = IRcurrentRg;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    //fprintf(IRcode, "sub $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    IRcurrentASMsg++;
                    IRcurrentRg = firstID;
                    break;
                }
                IRcurrentRg++;
            }
            break;
        }
        IRcurrentRg++;
    }
    break;

        case '*':
            while(IRcurrentRg < 6){
            if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            firstID = IRcurrentRg;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    //fprintf(IRcode, "mult $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    IRcurrentMDMsg++;
                    IRcurrentRg = firstID;
                    break;
                }
                IRcurrentRg++;
            }
            break;
        }
        IRcurrentRg++;
    }
    break;

        case '/':
            while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            firstID = IRcurrentRg;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    //fprintf(IRcode, "div $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    IRcurrentMDMsg++;
                    IRcurrentRg = firstID;
                    break;
                }
                IRcurrentRg++;
            }
            break;
            }
            IRcurrentRg++;
        }      
        break;
    }
    
}

// This function is used to emit the IR code for assigning a register to an NUMBER PLUS NUMBER and INTEGER PLUS INTEGER
void emitIRBinaryOperation(char op[1], const char* id1, const char* id2){
    switch (op[0]){
        case '+':
            //fprintf(IRcode, "addi $t7, $zero, %s \n", id1);
            //fprintf(IRcode, "add $t7, $t7, %s\n", id2);  
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $zero, %s \n", id1);
            IRcurrentASMsg++;
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $t7, %s\n", id2);
            IRcurrentASMsg++;
        break;

        case '-':
            //fprintf(IRcode, "subi $t7, $zero, %s \n", id1);
            //fprintf(IRcode, "sub $t7, $t7, %s\n", id2);  
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $zero, %s \n", id1);
            IRcurrentASMsg++;
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $t7, %s\n", id2);
            IRcurrentASMsg++;
        break;

        case '*':
            //fprintf(IRcode, "multi $t7, 1, %s \n", id1);
            //fprintf(IRcode, "mult $t7, $t7, %s\n", id2);  
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, 1, %s \n", id1);
            IRcurrentMDMsg++;
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, $t7, %s\n", id2);
            IRcurrentMDMsg++;
        break;

        case '/':
            //fprintf(IRcode, "divi $t7, 1, %s \n", id1);
            //fprintf(IRcode, "div $t7, $t7, %s\n", id2);  
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, 1, %s \n", id1);
            IRcurrentMDMsg++;
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, $t7, %s\n", id2);
            IRcurrentMDMsg++;
        break;
    }

}

// This function is used to emit the IR code for adding a register to a NUMBER PLUS ID
void emitIRNumIDBinaryOperation(char op[1], const char* id1, const char* id2){
    IRcurrentRg = 0;
    switch(op[0]){
        case '+':
            //fprintf(IRcode, "addi $t7, $zero, %s \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $zero, %s \n", id1);
            IRcurrentASMsg++;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                //fprintf(IRcode, "add $t7, $t7, $t%d\n", IRcurrentRg);
                sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $t7, $t%d\n", IRcurrentRg);
                IRcurrentASMsg++;
                break;
            }
            IRcurrentRg++;
        }
        break;

        case '-':
            //fprintf(IRcode, "subi $t7, $zero, %s \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $zero, %s \n", id1);
            IRcurrentASMsg++;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                //fprintf(IRcode, "sub $t7, $t7, $t%d\n", IRcurrentRg);
                sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $t7, $t%d\n", IRcurrentRg);
                IRcurrentASMsg++;
                break;
            }
            IRcurrentRg++;
        }
        break;

        case '*':
            //fprintf(IRcode, "multi $t7, 1, %s \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "MULTIPLY $t7, 1, %s \n", id1);
            IRcurrentASMsg++;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                //fprintf(IRcode, "mult $t7, $t7, $t%d\n", IRcurrentRg);
                sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, $t7, $t%d\n", IRcurrentRg);
                IRcurrentMDMsg++;
                break;
            }
            IRcurrentRg++;
        }
        break;

        case '/':
            //fprintf(IRcode, "divi $t7, 1, %s \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "DIVIDE $t7, 1, %s \n", id1);
            IRcurrentASMsg++;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                //fprintf(IRcode, "div $t7, $t7, $t%d\n", IRcurrentRg);
                sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, $t7, $t%d\n", IRcurrentRg);
                IRcurrentMDMsg++;
                break;
            }
            IRcurrentRg++;
        }
        break;
    }      

}
// Function for adding an ID plus ARITH (Long expression that recursively calls itself)
void emitIRBinaryOperationArith(char op[1], const char* id1){
    IRcurrentRg = 0;
    
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            switch (op[0]){
        case '+':
            //fprintf(IRcode, "addi $t7, $t%d, $t7 \n", IRcurrentRg);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, $t%d, $t7 \n", IRcurrentRg);
            IRcurrentASMsg++;
        break;

        case '-':
            //fprintf(IRcode, "subi $t7, $t%d, $t7 \n", IRcurrentRg);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUBTRACT $t7, $t%d, $t7 \n", IRcurrentRg);
            IRcurrentASMsg++;
        break;

        case '*':
            //fprintf(IRcode, "multi $t7, $t%d, $t7 \n", IRcurrentRg); 
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, $t%d, $t7 \n", IRcurrentRg);
            IRcurrentMDMsg++;
        break;

        case '/':
            //fprintf(IRcode, "divi $t7, $t%d, $t7 \n", IRcurrentRg);
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, $t%d, $t7 \n", IRcurrentRg);
            IRcurrentMDMsg++;
        break;
    }
        }
        IRcurrentRg++;
    }      
}

// Function for adding an NUMBER plus ARITH (Long expression that recursively calls itself)
void emitIRNumBinaryOperationArith(char op[1], const char* id1){
    switch (op[0]){
        case '+':
            //fprintf(IRcode, "addi $t7, %s, $t7 \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "ADD $t7, %s, $t7 \n", id1);
            IRcurrentASMsg++;
        break;

        case '-':
            //fprintf(IRcode, "subi $t7, %s, $t7 \n", id1);
            sprintf(IRaSMsgs[IRcurrentASMsg].Irvariable, "SUB $t7, %s, $t7 \n", id1);
            IRcurrentASMsg++;
        break;

        case '*':
            //fprintf(IRcode, "multi $t7, %s, $t7 \n", id1); 
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "MULTIPLY $t7, %s, $t7 \n", id1);
            IRcurrentMDMsg++;
        break;

        case '/':
            //fprintf(IRcode, "divi $t7, %s, $t7 \n", id1);
            sprintf(IRmDMsgs[IRcurrentMDMsg].Irvariable, "DIVIDE $t7, %s, $t7 \n", id1);
            IRcurrentMDMsg++;
        break;
    }
}

// This function is used to emit the IR code for an emit assignment for ARITH where we load the output of a function into the last register
// For instance z = x + y... would need emitArithAssignment for z
void emitIRArithAssignment (char id1[50]){
    int exists = 0;
    IRcurrentRg = 0;
    
    IRprintMessages();

    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            fprintf(IRcode, "MOVE $t%d, $t7\n", IRcurrentRg);
            exists = 1;
            break;
        }
        IRcurrentRg++;
    }
    if(exists != 1){
        IRcurrentRg = 0;
        while(IRcurrentRg < 6){
            if(IRregisterUsed[IRcurrentRg] == 0){
                fprintf(IRcode, "MOVE $t%d, $t7\n", IRcurrentRg);
                //fprintf(IRcode, "%s = ASSIGN T%d\n", id1, IRcurrentRg);
                IRregisterUsed[IRcurrentRg] = 1;
                strcpy(IRIrvariableReg[IRcurrentRg].Irvariable, id1);
                break;
            }
            if(IRcurrentRg == 6){
                fprintf(IRcode, "\nERROR: No registers available.");
                break;
            }
            IRcurrentRg++;
        }
    }
    
}
// This function is used to emit IR Code assignment statements for ID = ID.
// Works the same as emitArithAssignment but does not use the last register instead the next available register.
void emitIRAssignment(char * id1, char * id2){
  // This is the temporary approach, until register management is implemented
    int exists = 0;
    int firstID = 0;
    IRcurrentRg = 0;
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            firstID = IRcurrentRg;
            exists = 1;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    fprintf(IRcode, "MOVE $t%d, $t%d\n", firstID, IRcurrentRg);
                    IRcurrentRg = firstID;
                    break;
                }
                IRcurrentRg++;
            }
            break;
        }
        IRcurrentRg++;
    }
    if(exists != 1){
        IRcurrentRg = 0;
        while(IRcurrentRg < 6){
            if(IRregisterUsed[IRcurrentRg] == 0){
                IRregisterUsed[IRcurrentRg] = 1;
                firstID = IRcurrentRg;
                strcpy(IRIrvariableReg[IRcurrentRg].Irvariable, id1);
                IRcurrentRg = 0;
                while(IRcurrentRg < 6){
                    if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                        fprintf(IRcode, "MOVE $t%d, $t%d\n", firstID, IRcurrentRg);
                        //fprintf(IRcode, "%s = ASSIGN T%d\n", id1, firstID);
                        break;
                    }
                    IRcurrentRg++;
                }                
                break;
            }
            if(IRcurrentRg == 6){
                fprintf(IRcode, "\nERROR: No registers available.");
                break;
            }
            IRcurrentRg++;
        }
    }
}
// This function is used to emit IR code for assignment statements for ID = Number.
// Works the same as emitArithAssignment but does not use the last register instead the next available register.
void emitIRConstantIntAssignment (char id1[50], char id2[50]){
    int exists = 0;
    IRcurrentRg = 0;
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id1) == 0){
            fprintf(IRcode, "LOADITEM $t%d, %s\n", IRcurrentRg, id2);
            exists = 1;
            break;
        }
        IRcurrentRg++;
    }
    if(exists != 1){
        IRcurrentRg = 0;
        while(IRcurrentRg < 6){
            if(IRregisterUsed[IRcurrentRg] == 0){
                fprintf(IRcode, "LOADITEM $t%d, %s\n", IRcurrentRg, id2);
                //fprintf(IRcode, "%s = ASSIGN T%d\n", id1, IRcurrentRg);
                IRregisterUsed[IRcurrentRg] = 1;
                strcpy(IRIrvariableReg[IRcurrentRg].Irvariable, id1);
                break;
            }
            if(IRcurrentRg == 6){
                fprintf(IRcode, "\nERROR: No registers available.");
                break;
            }
            IRcurrentRg++;
        }
    }
}

void emitIRConstantFlAssignment (char id1[50], char id2[50]){
    IRcurrentRg = 0;
    while(IRcurrentRg < 4){
        if(strcmp(Irfloats[IRcurrentRg].Irvariable, id1) == 0){
            fprintf(IRcode, "STOREWORD $f%d, %s\n", IRcurrentRg, Irfloats[IRcurrentRg].Irvariable);
            break;
        }
        IRcurrentRg++;
    }    
}

void emitIRArrayAssignmentID(char id1[50], int index, char id2[50]){
    IRcurrentRg = 0;
    int first;
    while(IRcurrentRg < 2){
        if(strcmp(Irarry[IRcurrentRg].Irvariable, id1) == 0 && index < IrarrySize[IRcurrentRg]){
            first = IRcurrentRg;
            IRcurrentRg = 0;
            while(IRcurrentRg < 6){
                if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id2) == 0){
                    //fprintf(IRcode, "add $t7, $t%d, $t%d\n", firstID, IRcurrentRg);
                    fprintf(IRcode, "MOVE $t7, $t%d\n", IRcurrentRg);
                    fprintf(IRcode, "LOADITEM $t8, %d\n", index);
                    fprintf(IRcode, "MULTIPLY $t8, $t8, 4\n");
                    fprintf(IRcode, "ADDITION $t8, $t8, $s%d\n", first);
                    fprintf(IRcode, "STOREWORD $t7, 0($t8)\n");
                    IRcurrentASMsg++;
                    IRcurrentRg = first;
                    break;
                }
                IRcurrentRg++;
            }
            break;
        }
        IRcurrentRg++;
    }
}

void emitIRArrayAssignmentConst(char id1[50], int index, char id2[50]) {
    IRcurrentRg = 0;
    while(IRcurrentRg < 2){
        if(strcmp(Irarry[IRcurrentRg].Irvariable, id1) == 0 && index < IrarrySize[IRcurrentRg]){
            fprintf(IRcode, "LOADITEM $t7, %s\n", id2);
            fprintf(IRcode, "LOADITEM $t8, %d\n", index);
            fprintf(IRcode, "MULTIPLY $t8, $t8, 4\n");
            fprintf(IRcode, "ADD $t8, $t8, $s%d\n", IRcurrentRg);
            fprintf(IRcode, "STOREWORD $t7, 0($t8)\n");
            break;
        }
        IRcurrentRg++;
    }
}

void functionDeclarationIR(char * id){
    fprintf(IRcode, "\nJUMP END%s\n", id);
    fprintf(IRcode, "%s:\n", id);
    strcpy(IRfuncs, id);
}

void returnIR(char * id){
    IRcurrentRg = 0;
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
            //fprintf(IRcode, "add $t7, %s, $t%d\n", id1, IRcurrentRg);
            fprintf(IRcode, "ADD $t7, $zero, $t%d \n", IRcurrentRg);
            break;
        }
        IRcurrentRg++;
    }
    fprintf(IRcode, "\nJUMP CALL%s\n", IRfuncs);
    fprintf(IRcode, "END%s:\n", IRfuncs);
}

void IRIDFuncAssignment(char * id, char * func){
    fprintf(IRcode, "\nJUMP %s", func);
    fprintf(IRcode, "\nCALL%s:\n", IRfuncs);
    IRcurrentRg = 0;
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
            fprintf(IRcode, "MOVE $t%d, $t7\n", IRcurrentRg);
            break;
        }
        IRcurrentRg++;
    }
}

void emitIRWriteId(char * id){
    int exists = 0;
    IRcurrentRg = 0;
    while(IRcurrentRg < 6){
        if(strcmp(IRIrvariableReg[IRcurrentRg].Irvariable, id) == 0){
            fprintf(IRcode, "\nLOADITEM $v0, 1\nMOVE $a0, $t%d\n\n", IRcurrentRg);
            fprintf(IRcode, "LOADITEM $v0, 4\nLOADADDRESS $a0, newline\n\n");
            exists = 1;
            break;
        }
        IRcurrentRg++;
    }
}

void IRprintMessages(){

    for (int i = 0; i < IRcurrentMDMsg; i++) {
        if (IRmDMsgs[i].Irvariable[0] != '\0') {
            fprintf(IRcode, "%s", IRmDMsgs[i].Irvariable);
            IRmDMsgs[i].Irvariable[0] = '\0';  // Clear the array element after printing
        }
    }
    for (int i = 0; i < IRcurrentASMsg; i++) {
        if (IRaSMsgs[i].Irvariable[0] != '\0') {
            fprintf(IRcode, "%s", IRaSMsgs[i].Irvariable);
            IRaSMsgs[i].Irvariable[0] = '\0';  // Clear the array element after printing
        }
    }
    IRcurrentMDMsg = 0;
    IRcurrentASMsg = 0;
}

void emitEndOfIRCode(){
    fprintf(IRcode, "# -----------------\n");
}

void emitEndOfInitIRCode(){
    fprintf(IRInitCode, "# -----------------------\n");
    fclose(IRInitCode);
}

#include <stdio.h>

void appendIRFiles() {
    FILE *IRcode;
    FILE *IRInitCode;

    // Open the source file (IRcode.ir) for reading
    IRcode = fopen("IRcode.ir", "r");

    if (IRcode == NULL) {
        fprintf(stderr, "Error opening IRcode.ir for reading.\n");
        return;
    }

    // Open the destination file (IRinit.asm) for appending
    IRInitCode = fopen("IRMain.ir", "a");

    if (IRInitCode == NULL) {
        fprintf(stderr, "Error opening IRinit.asm for appending.\n");
        fclose(IRcode);  // Close the source file
        return;
    }

    char ch;

    // Read and write each character from the source file (IRcode.ir) to the destination file (IRinit.asm)
    while ((ch = fgetc(IRcode)) != EOF) {
        fputc(ch, IRInitCode);
    }

    // Close the files
    fclose(IRcode);
    fclose(IRInitCode);
}