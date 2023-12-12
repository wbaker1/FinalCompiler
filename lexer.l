%option noyywrap

%{
#include <stdio.h>
#include <string.h>

#define YY_DECL int yylex()
#include "parser.tab.h"

int words = 0;
int chars = 0;
int lines = 0;

%}

letter      [a-zA-Z]
digit       [0-9]
ID          {letter}({letter}|{digit})*
delim       [ \t\n]
INTEGER		{digit}+
NUMBER      {digit}+(\.{digit}+)
CHARACTER	\"{letter}\"
ws          {delim}+

%%
"/*"    				{
							int c;
							while((c = input()) != 0) {
								if(c == '*') {
									if((c = input()) == '/')
										break;
									else
										unput(c);
								}
							}
						}
						
"int"	{words++; chars += strlen(yytext);
			printf("%s : TYPE\n", yytext);
			yylval.string = strdup(yytext); 
			return TYPE;
		}

"float"	{words++; chars += strlen(yytext);
			printf("%s : TYPE\n", yytext);
			yylval.string = strdup(yytext); 
			return TYPE;
		}

"char"	{words++; chars += strlen(yytext);
			printf("%s : TYPE\n", yytext);
			yylval.string = strdup(yytext); 
			return TYPE;
		}

"if"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return IF;
		}

"endif"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return ENDIF;
		}

"else"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return ELSE;
		}

"endelse"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return ENDELSE;
		}
		
"while"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return WHILE;
		}
		
"endwhile"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return ENDWHILE;
		}

"write"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return WRITE;
		}

"writeln"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return WRITELN;
		}

"return"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return RETURN;
		}

"read"	{words++; chars += strlen(yytext);
			printf("%s : KEYWORD\n", yytext);
			yylval.string = strdup(yytext); 
			return READ;
		}

{ID}	{words++; chars += strlen(yytext);
			  printf("%s : IDENTIFIER\n",yytext);
			  yylval.string = strdup(yytext); 
			  return ID;
			}

{INTEGER}	{words++; chars += strlen(yytext);
			  printf("%s : INTEGER\n",yytext);
			  yylval.number = atoi(strdup(yytext)); 
			  return INTEGER;
			}
			
{NUMBER}    { words++; chars += strlen(yytext);
              printf("%s : NUMBER\n", yytext);
              yylval.fl = atof(yytext); // Use yylval.fl for float values
              return NUMBER;
            }

{CHARACTER}	{chars++;
			  printf("%s : CHARACTER\n",yytext);
			  yylval.string = strdup(yytext);
			  return CHARACTER;
			}

","		{chars++;
		  printf("%s : COMMA\n", yytext);
		  yylval.string = strdup(yytext); 
		  return COMMA;
		}
			
";"		{chars++;
		  printf("%s : SEMICOLON\n", yytext);
		  yylval.string = strdup(yytext); 
		  return SEMICOLON;
		}

":"		{chars++;
		  printf("%s : COLON\n", yytext);
		  yylval.string = strdup(yytext); 
		  return COLON;
		}
		
"="		{chars++;
		  printf("%s : EQ\n", yytext);
		  yylval.string = strdup(yytext); 
		  return EQ;
		}

"+"	{chars++;
		 printf("%s : PLUS\n", yytext);
		 yylval.string = strdup(yytext);
		 return PLUS;
		}

"-"	{chars++;
		 printf("%s : MINUS\n", yytext);
		 yylval.string = strdup(yytext);
		 return MINUS;
		}

"--"	{chars+2;
		 printf("%s : UNARY\n", yytext);
		 yylval.string = strdup(yytext);
		 return UNARY;
		}

"*"	{chars++;
		 printf("%s : MULT\n", yytext);
		 yylval.string = strdup(yytext);
		 return MULT;
		}

"<"	{chars++;
		 printf("%s : LT\n", yytext);
		 yylval.string = strdup(yytext);
		 return LT;
		}

">"	{chars++;
		 printf("%s : GT\n", yytext);
		 yylval.string = strdup(yytext);
		 return GT;
		}

"=="	{words++; chars += strlen(yytext);
		 printf("%s : EQUIV\n", yytext);
		 yylval.string = strdup(yytext);
		 return EQUIV;
		}

"/"	{chars++;
		 printf("%s : DIVIDE\n", yytext);
		 yylval.string = strdup(yytext);
		 return DIVIDE;
		}

"("	{chars++;
		 printf("%s : LEFTPAREN\n", yytext);
		 yylval.string = strdup(yytext);
		 return LEFTPAREN;
		}

")"	{chars++;
		 printf("%s : RIGHTPAREN\n", yytext);
		 yylval.string = strdup(yytext);
		 return RIGHTPAREN;
		}

"["	{chars++;
		 printf("%s : LEFTBRACKET\n", yytext);
		 yylval.string = strdup(yytext);
		 return LEFTBRACKET;
		}

"]"	{chars++;
		 printf("%s : RIGHTBRACKET\n", yytext);
		 yylval.string = strdup(yytext);
		 return RIGHTBRACKET;
		}

"{"	{chars++;
		 printf("%s : LEFTCBRACE\n", yytext);
		 yylval.string = strdup(yytext);
		 return LEFTCBRACE;
		}

"}"	{chars++;
		 printf("%s : RIGHTCBRACE\n", yytext);
		 yylval.string = strdup(yytext);
		 return RIGHTCBRACE;
		}

"\""	{chars++;
		 printf("%s : QUOTE\n", yytext);
		 yylval.string = strdup(yytext);
		 return QUOTE;
		}
		
[\n]	{lines++; chars=0;}
[ \t]	{chars++;}
.		{chars++;
         printf("%s : Unrecognized symbol at line %d char %d\n", yytext,lines,chars);
		}
		

%%