%option noyywrap
%x multicomment
%x stringstate 
%x SingleLineComment
%{


#include<bits/stdc++.h>
#include "1505032_symboltable.h"
# include "y.tab.h"


using namespace std;

void yyerror(char*);
extern YYSTYPE yylval;

ofstream fileerror("1505032_log.txt");
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
int semerror=0;
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

CHAR [ -~]{-}['\\\n]	
CHARACTER('{CHAR}') 
MULTCHAR('{CHAR}[ -~]+') 
EMPTYCHAR ('') 
UNFINCHAR('{CHAR}*)
SLASH('\\')
UNIQUE('\\[ntafrbv0"\\]')


Letter [A-Za-z]
Digit[0-9]



INTEGER {Digit}+
ID (_|{Letter})(_|{Letter}|{Digit})* 
 		
  




ERRID {Digit}+({ID}) 		
  

FLOAT   {Digit}*(\.{Digit}+)?(E[+-]?{Digit}+)?
IllFormFloat {Digit}*((\.{Digit}+)?(E[+-]?{Digit}*\.{Digit}*)|(\.{Digit}+)?(E[+-]?))
TooDecFloat {Digit}*(\.{Digit}*|\.E[+-]?{Digit}*)(\.{Digit}*|\.E[+-]?{Digit}*)


%%
"\r\n"           {linecount++ ;}
\n	        {linecount++ ;}

{WHITESPACE}    {space=yytext;}	


\"            { lcl=0;
                  errorline=linecount;
                  ss=yytext;
                  //yytext++; 
               
                  ssn="";
                    BEGIN(stringstate);} 
                  
<stringstate>\"    { 
                   ss+=yytext;
                  linecount+=lcl;
                  // cout<<linecount<<endl;
                  
                     

                   BEGIN (INITIAL);}

<stringstate>\\\n|\\\r\n     {ss+=yytext;lcl++;}

<stringstate>\\[ntafrbv0"\\]       { 
                        
                       if(yytext[1]=='n')
                         { ssn+='\n';
                          }
                        else  if(yytext[1]=='t')
                         { ssn+='\t';
                          }
                         else  if(yytext[1]=='a')
                         { ssn+='\a';
                          }
                         else if(yytext[1]=='f')
                         { ssn+='\f';
                          }
                         else if(yytext[1]=='r')
                         { ssn+='\r';
                          }
                         else if(yytext[1]=='b')
                         { ssn+='\b';
                          }
                         else if(yytext[1]=='v')
                         { ssn+='\v';
                          }
                          else if(yytext[1]=='0')
                         { ssn+='\0';
                          }
                          else if(yytext[1]=='\\')
                         { ssn+='\\';
                          }
                          else
                         { ssn+='\"';
                          }
                         ss+=yytext;
                         
                        }

<stringstate>\n     {
                      lcl++;
                      errorcount++;
                      semerror++;
                      ss+=yytext;
                     fileerror<<"Error at line :"<<errorline<<" Unterminated string "<<ss<<"Found\n"<<endl;
                       linecount+=lcl;
                     BEGIN(INITIAL);}

<stringstate>.	        {ss+=yytext; ssn+=yytext;}  


<stringstate><<EOF>> {  linecount+=lcl;fileerror<<"Error at line :"<<errorline<<" Unterminated string "<<ss<<"Found\n"<<endl;
                       
                     BEGIN(INITIAL);}



"//"            { lcl=0; errorline=linecount;comment=yytext; cout<<"comment starts"<<endl;BEGIN(SingleLineComment);}


<SingleLineComment>"\\\n" {lcl++;cout<<"comment continues"<<endl;}


<SingleLineComment>\n {lcl++;  
                     cout<<comment<<endl;cout<<"comment finished"<<endl;
                    
                     linecount+=lcl;   
                     BEGIN(INITIAL);}
<SingleLineComment>.  {comment+=yytext;}
<SingleLineComment><<EOF>> {  BEGIN(INITIAL);}


"/*"		{lcl =0; str = yytext ;
                  errorline=linecount;
                  
                    BEGIN(multicomment) ;}

<multicomment>"*/"      {str+=yytext;
                  cout <<  "mycomment"<<str << endl ;
                  linecount+=lcl;
                   cout<<linecount<<endl;
                  

                      BEGIN (INITIAL);}

<multicomment><<EOF>>   {cout<<"Error !! unfinished comment !"<<endl;
                          errorcount++;
                          semerror++;
                          lcl++;
                          linecount+=lcl;
                        fileerror<<"Error at Line "<<errorline<<": Unterminated Comment   "<<str<<" Found\n"<<endl;
                      BEGIN(INITIAL);}

<multicomment>.	        {str+=yytext;}

<multicomment>\n        {str+=yytext;lcl++;}




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
                       s->setname(yytext);
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
                      s->setname(yytext);
                      s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                     return INCOP; }
{DECOP}   {//cout<<"DECOP==>"<<yytext<<endl;
                 cout << "Line no: "<< linecount<<" TOKEN <DECOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                       s->setname(yytext);
                     s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return DECOP;}
{RELOP}   {//cout<<"RELOP==>"<<yytext<<endl;
                  cout << "Line no: "<< linecount<<" TOKEN <RELOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                   s->setname(yytext);
                  s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return RELOP;}

{ASSIGNOP}  {//cout<<"ASSINGOP==>"<<yytext<<endl;
                 cout << "Line no: "<< linecount<<" TOKEN <ASSIGNOP> Lexeme " << yytext <<" found\n" ;
                      symbol *s =new  symbol();
                     s->setname(yytext);
                   s->settext(space+yytext);
                       space="";
                      yylval.p= s;
                      return ASSIGNOP;}

{LOGICOP}  {//cout<<"LOGICOP==>"<<yytext<<endl;
           cout<< "Line no: "<< linecount<<" TOKEN <LOGICOP> Lexeme " << yytext <<" found\n" ;
                    symbol *s =new  symbol();
                     s->setname(yytext);
                    s->settext(space+yytext);
                      space="";
                     yylval.p= s;
                    return LOGICOP;}

"println" {cout << "Line no: "<< linecount<<" Token <PRINTLN> Lexeme "<<yytext<<" found\n";
                       symbol *s =new  symbol();
                        s->setname(yytext);
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



{CHARACTER}     {string ch;
           
               ch=yytext[1];
               fileerror<<"Line No :"<<linecount<<" Token <CONST_CHAR> Lexeme "<<yytext<<"Found\n"; 
               
                 }

{SLASH}          {errorcount++;semerror++;
                   fileerror<<"Error at line : "<<linecount<<" Unterminated character error "<<yytext<<endl<<endl;} 

{UNFINCHAR}     { errorcount++;semerror++;
                  fileerror<<"Error at line : "<<linecount<<" Unterminated character error "<<yytext<<endl<<endl;}

{EMPTYCHAR}     { errorcount++;semerror++;
                   fileerror<<"Error at line :"<<linecount<<" Empty character constant error"<<yytext<<endl<<endl;}

{MULTCHAR}       {  errorcount++;semerror++;
                    fileerror<<"Error at line :"<<linecount<<" Multi character constant error"<<yytext<<endl<<endl;}
{UNIQUE}         {
	          
                     string ch1;
                     if(yytext[2]=='n') 
                        {
                        
                          ch1='\n';

			  
 
                       
                         }
                       else if(yytext[2]=='t') 
                        {
                        
                          ch1='\t'; 
                        
    
                         
                         }
                        else if(yytext[2]=='a') 
                        {
                         
                          ch1='\a';
                       
                         
                         }

                         else if(yytext[2]=='f') 
                        {
                       
                          ch1='\f';
                     
                            
                        }

                        else if(yytext[2]=='r') 
                        {
                          
                          ch1='\r';
                      
                            
                         }

                        else if(yytext[2]=='b') 
                        {
                         cout<<"\b"; 
                          ch1='\b';
                     
                         
                         }
                         else if(yytext[2]=='v') 
                        {
                         cout<<"\v"; 
                        
                        
                         }
                        else if(yytext[2]=='0') 
                        {
                          
                          ch1='\0';
                       
                         }
                         else if(yytext[2]=='\\') 
                        {
                         cout<<"\\"; 
                       
                       
                         }
                          else
                        {
                         cout<<"\""; 
                       
                        
                         }

                   
                      

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

{IllFormFloat} { errorcount++;semerror++;
                 fileerror<<"Error at Line :"<<linecount<<" Ill formed  Number "<<yytext<<endl<<endl;}

{TooDecFloat}   {  errorcount++;semerror++;
                  fileerror<<"Error at Line :"<<linecount<<" Too many decimal point number  "<<yytext<<endl<<endl;}



{ERRID}        {fileerror<<"Error at Line :"<<linecount<<" Invalid Prefix on ID or Invalid suffix on Number  "<<yytext<<endl<<endl; 
                  errorcount++;semerror++; }                  

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
            
            

.		{ errorcount++;semerror++; fileerror<<"Error at line :"<<linecount<<" Unrecognized character "<<yytext<<"Found\n"<<endl;} 

%%

 

 

