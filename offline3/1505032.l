%option noyywrap

%{


#include<bits/stdc++.h>
#include "1505032_symboltable.h"
# include "y.tab.h"

using namespace std;

void yyerror(char*);
extern YYSTYPE yylval;

string newline="\n";
string space;
string str ;
string ss;
string comment;
int linecount = 1 ;
int lcl=0;
int errorline=0;
int i;
string ssn;
int errorcount=0;
%}

ADDOP("+"|"-")
MULOP("*"|"/"|"%")
INCOP("++")
DECOP("--")
RELOP("<"|"<="|">"|">="|"=="|"!=")
ASSIGNOP("=")
LOGICOP("&&"|"||")
BITOP("&"|"|"|"^"|"<<"|">>")

WHITESPACE 	[ \t\f\r\v]+	



Letter [A-Za-z]
Digit[0-9]



INTEGER {Digit}+
ID (_|{Letter})(_|{Letter}|{Digit})* 
 		
  

FLOAT   {Digit}*(\.{Digit}+)(E[+-]?{Digit}+)?




%%
"\r\n"           {linecount++ ;}
\n	        {linecount++ ;}

{WHITESPACE}    {space=yytext;}	




"if"       { //cout<< "<IF>\n"; 
                cout << "Line no: "<< linecount<<" Token <IF> Lexeme if found\n";
                       symbol *s =new  symbol();
                     s->settext(space+yytext);
                      space="";
                       yylval.p= s; 
                       return IF;} 
"else"     { //cout<< "<ELSE>\n"; 
                cout << "Line no: "<< linecount<<" Token <ELSE> Lexeme else found\n";
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                         space="";
                       yylval.p= s; 
                       return ELSE;}
"for"      {// cout<< "<FOR>\n"; 
             cout << "Line no: "<< linecount<<" Token <FOR> Lexeme for found\n";
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                        space="";
                       yylval.p= s; 
                       return FOR; }
"while"       { //cout<< "<IF>\n"; 
                cout << "Line no: "<< linecount<<" Token <WHILE> Lexeme if found\n";
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                        space="";
                       yylval.p= s; 
                       return WHILE;} 
"int"      { //cout<< "<INT>\n"; 
                   cout << "Line no: "<< linecount<<" Token <INT> Lexeme int found\n"; 
                       symbol *s =new  symbol();
                  s->settext(space+yytext);
                       space="";
                       yylval.p= s; 
                       return INT;}

"float"    {// cout<< "<FLOAT>\n"; 
                 cout<< "Line no: "<< linecount<<" Token <FLOAT> Lexeme float found\n";
                       symbol *s =new  symbol();
                        s->settext(space+yytext);
                         space="";
                       yylval.p= s; 
                       return FLOAT; }

"void"     { //cout<< "<VOID>\n"; 
           cout<< "Line no: "<< linecount<<" Token <VOID> Lexeme void found\n"; 
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                        space="";
                       yylval.p= s; 
                       return VOID;}
"return"   { //cout<< "<RETURN>\n"; 
                 cout<< "Line no: "<< linecount<<" Token <RETURN> Lexeme return found\n";
                       symbol *s =new  symbol();
                     s->settext(space+yytext);
                        space="";
                       yylval.p= s; 
                       return RETURN;}




{ADDOP} {//cout<<"ADDOP==>"<<yytext<<endl;
            cout << "Line no: "<< linecount<<" TOKEN <ADDOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                       s->settext(space+yytext);
                        space="";
                      yylval.p= s;
                      return ADDOP;     }

{MULOP}   {//cout<<"MULOP==>"<<yytext<<endl; 
              cout<< "Line no: "<< linecount<<" TOKEN <MULOP> Lexeme " << yytext <<" found\n" ;
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                      s->setname(yytext);
                        space="";
                       yylval.p= s;
                       return MULOP; }
{INCOP}   {//cout<<"INOP==>"<<yytext<<endl;
                 cout << "Line no: "<< linecount<<" TOKEN <INOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                      s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                     return INCOP; }
{DECOP}   {//cout<<"DECOP==>"<<yytext<<endl;
                 cout << "Line no: "<< linecount<<" TOKEN <DECOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                     s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return DECOP;}
{RELOP}   {//cout<<"RELOP==>"<<yytext<<endl;
                  cout << "Line no: "<< linecount<<" TOKEN <RELOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                  s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return RELOP;}

{ASSIGNOP}  {//cout<<"ASSINGOP==>"<<yytext<<endl;
                 cout << "Line no: "<< linecount<<" TOKEN <ASSIGNOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                   s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return ASSIGNOP;}

{LOGICOP}  {//cout<<"LOGICOP==>"<<yytext<<endl;
           cout<< "Line no: "<< linecount<<" TOKEN <LOGICOP> Lexeme " << yytext <<" found\n" ;
                    symbol *s =new  symbol();
                    s->settext(space+yytext);
                      space="";
                     yylval.p= s;
                    return LOGICOP;}

"println" {cout << "Line no: "<< linecount<<" Token <PRINTLN> Lexeme "<<yytext<<" found\n";
                       symbol *s =new  symbol();
                      s->settext(space+yytext);
                        space="";
                       yylval.p= s; 
                       return PRINTLN; }



"!"     {//cout<<"NOT==>"<<yytext<<endl;
               cout  << "Line no: "<< linecount<<" TOKEN <NOT> Lexeme " << yytext <<" found\n" ; 
                   symbol *s =new  symbol();
                 s->settext(space+yytext);
                    space="";
                   yylval.p= s;
                   return NOT;
                 }
"("      {//cout<<"LPAREN==>"<<yytext<<endl;
               cout  << "Line no: "<< linecount<<" TOKEN <LPAREN> Lexeme " << yytext <<" found\n" ;
                     symbol *s =new  symbol();
                      s->settext(yytext);
                       space="";
                     yylval.p= s;
                     return LPAREN;
                  }
")"       {//cout<<"RPAREN==>"<<yytext<<endl;
                cout << "Line no: "<< linecount<<" TOKEN <RAREN> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                      cout<<"newline==>"<<newline;
                      s->settext(space+yytext);
                         space="";
                       //newline="";
                      yylval.p= s;
                      return RPAREN;
               }
"{"        {//cout<<"LCURL==>"<<yytext<<endl;
                 cout  << "Line no: "<< linecount<<" TOKEN <LCURL> Lexeme " << yytext <<" found\n" ; 
                    symbol *s =new  symbol();
                     s->settext(space+yytext+newline);
                        space="";
                     //newline="";
                      yylval.p= s;
                     return LCURL;
                 }
"}"          {//cout<<"RCURL==>"<<yytext<<endl;
                 cout  << "Line no: "<< linecount<<" TOKEN <RCURL> Lexeme " << yytext <<" found\n" ; 
                     symbol *s =new  symbol();
                   s->settext(space+yytext+newline);
                      //  newline="";
                        space="";
                       yylval.p= s;
                    return RCURL;
                 }
"["         {//cout<<"LTHIRD==>"<<yytext<<endl;
                     cout << "Line no: "<< linecount<<" TOKEN <LTHIRD> Lexeme " << yytext <<" found\n" ;
                       symbol *s =new  symbol();
                    s->settext(space+yytext);
                        space="";
                       yylval.p= s;
                       return LTHIRD;
                 }
"]"          {//cout<<"RTHIRD==>"<<yytext<<endl;
                      cout  << "Line no: "<< linecount<<" TOKEN <RTHIRD> Lexeme"<<yytext<<"found\n";
                      symbol *s =new  symbol();
                  s->settext(space+yytext);
                       space="";
	              yylval.p= s;
                      return RTHIRD;
                 }
","           {//cout<<"COMMA==>"<<yytext<<endl;
                      cout  << "Line no: "<< linecount<<" TOKEN <COMMA> Lexeme " << yytext <<" found\n" ;

                      symbol *s =new  symbol();
                   s->settext(space+yytext);
                       space="";
	              yylval.p= s;
                    return COMMA;
               }
";"            {//cout<<"SEMICOLON==>"<<yytext<<endl;
                        cout  << "Line no: "<< linecount<<" TOKEN <SEMICOLON> Lexeme " << yytext <<" found\n" ; 
                      symbol *s =new  symbol();
                      s->settext(space+yytext+newline);
                       //newline="";
                      //cout<<"semicolon is==>"<<s->line;
                       space="";
	              yylval.p= s;
                     return SEMICOLON;
                 }





{INTEGER}  {
            
            cout<<"<INTEGER,"<<yytext<<">\n";
                 symbol *s =new  symbol();
                    s->settext(space+yytext);
                     space="";
                    s->setname(yytext);
                    s->settype("CONST_INT");
	            yylval.p= s;
                    return CONST_INT;
           }  


{FLOAT}         {
                  
                  cout<<"<CONST_FLOAT,"<<yytext<<">\n";
                    symbol *s =new  symbol();
                    s->settext(space+yytext);
                    space="";
                    s->setname(yytext);
                    s->settype("CONST_FLOAT");
	            yylval.p= s;
                    return CONST_FLOAT;
                 
                  }

                   

{ID}            {
                 cout<<"<ID,"<<yytext<<">\n";
                 
                     symbol *s =new  symbol();
                     s->settext(space+yytext);
                     space="";
                     s->setname(yytext);
                     s->settype("ID");
	             yylval.p= s;
			
                     return ID;
                } 
            
            

.		{ errorcount++; cout<<"Error at line :"<<linecount<<" Unrecognized character "<<yytext<<"Found"<<endl;} 

%%

 

 

