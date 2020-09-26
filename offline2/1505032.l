%option noyywrap

%x multicomment
%x stringstate 
%x SingleLineComment

%{


#include"1505032_symboltable.h"
using namespace std;


symboltable st(7);

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
INCOP("++"|"--")
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
\n	        {linecount++ ;}
{WHITESPACE}    {}	

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
                   tokenlog<<"Line No : "<<errorline<<" Token <String> Lexeme "<<ss<< "  Found"<<endl ;
                     token << "<STRING,"<<ssn<< ">" ; 

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
                      ss+=yytext;
                     tokenlog<<"Error at line :"<<errorline<<" Unterminated string "<<ss<<"Found"<<endl;
                       linecount+=lcl;
                     BEGIN(INITIAL);}

<stringstate>.	        {ss+=yytext; ssn+=yytext;}  


<stringstate><<EOF>> {  linecount+=lcl; tokenlog<<"Error at line :"<<errorline<<" Unterminated string "<<ss<<"Found"<<endl;
                       
                     BEGIN(INITIAL);}



"//"            { lcl=0; errorline=linecount;comment=yytext;BEGIN(SingleLineComment);}


<SingleLineComment>\\\n|\\\r\n {lcl++;}


<SingleLineComment>\n {lcl++;  
                    
                     tokenlog<<"Line no :"<<errorline <<" Token <COMMENT> Lexeme "<<comment << " Found"<<endl ; 
                     linecount+=lcl;   
                     BEGIN(INITIAL);}
<SingleLineComment>.  {comment+=yytext;}

<SingleLineComment><<EOF>> { linecount+=lcl;  BEGIN(INITIAL);}


"/*"		{lcl =0; str = yytext ;
                  errorline=linecount;
                  
                    BEGIN(multicomment) ;}

<multicomment>"*/"      {str+=yytext;
                 
                  linecount+=lcl;
                  // cout<<linecount<<endl;
                  tokenlog<<"Line no :"<<errorline<<" Token <COMMENT> Lexeme "<<str << " Found"<<endl ;

                      BEGIN (INITIAL);}

<multicomment><<EOF>>   {
                          errorcount++;
                          lcl++;
                          linecount+=lcl;
                     tokenlog<<"Error at Line "<<errorline<<": Unterminated Comment   "<<str<<" Found"<<endl;
                      BEGIN(INITIAL);}

<multicomment>.	        {str+=yytext;}

<multicomment>\n        {str+=yytext;lcl++;}



"if"       { //cout<< "<IF>\n"; 
                tokenlog << "Line no: "<< linecount<<" Token <IF> Lexeme if found\n"; token<<" <IF> ";} 
"else"     { //cout<< "<ELSE>\n"; 
                tokenlog << "Line no: "<< linecount<<" Token <ELSE> Lexeme else found\n"; token<<" <ELSE> ";}
"for"      {// cout<< "<FOR>\n"; 
              tokenlog << "Line no: "<< linecount<<" Token <FOR> Lexeme for found\n"; token<<" <FOR> ";}
"while"    {// cout<< "<WHILE>\n";  
                tokenlog << "Line no: "<< linecount<<" Token <WHILE> Lexeme while found\n"; token<<" <WHILE> ";}
"do"       {// cout<< "<DO>\n";  
                 tokenlog << "Line no: "<< linecount<<" Token <DO> Lexeme do found\n"; token<<" <DO> ";}
"break"    {//cout<< "<BREAK>\n"; 
               tokenlog << "Line no: "<< linecount<<" Token <BREAK> Lexeme break found\n"; token<<" <BREAK> ";}
"int"      { //cout<< "<INT>\n"; 
                  tokenlog << "Line no: "<< linecount<<" Token <INT> Lexeme int found\n"; token<<" <INT> ";}
"char"     { //cout<< "<CHAR>\n"; 
                 tokenlog << "Line no: "<< linecount<<" Token <CHAR> Lexeme char found\n"; token<<" <CHAR> ";}
"float"    {// cout<< "<FLOAT>\n"; 
                 tokenlog << "Line no: "<< linecount<<" Token <FLOAT> Lexeme float found\n"; token<<" <FLOAT> ";}
"double"   { //cout<< "<DOUBLE>\n"; 
                 tokenlog << "Line no: "<< linecount<<" Token <DOUBLE> Lexeme double found\n"; token<<" <DOUBLE> ";}
"switch"   { //cout<< "<SWITCH>\n"; 
           tokenlog << "Line no: "<< linecount<<" Token <SWITCH> Lexeme switch found\n"; token<<" <SWITCH> ";}
"case"     { //cout<< "<CASE>\n"; 
            tokenlog << "Line no: "<< linecount<<" Token <CASE> Lexeme case found\n"; token<<" <CASE> ";}
"void"     { //cout<< "<VOID>\n"; 
           tokenlog << "Line no: "<< linecount<<" Token <VOID> Lexeme void found\n"; token<<" <VOID> ";}
"return"   { //cout<< "<RETURN>\n"; 
                tokenlog << "Line no: "<< linecount<<" Token <RETURN> Lexeme return found\n"; token<<" <RETURN> ";}
"default"  {// cout<< "<DEFAULT>\n";  
              tokenlog << "Line no: "<< linecount<<" Token <DEFAULT> Lexeme default found\n"; token<<" <DEFAULT> ";}
"continue" { //cout<< "<CONTINUE>\n";  
              tokenlog << "Line no: "<< linecount<<" Token <CONTINUE> Lexeme continue found\n"; token<<" <CONTINUE> ";}


{ADDOP} {//cout<<"ADDOP==>"<<yytext<<endl;
           tokenlog << "Line no: "<< linecount<<" TOKEN <ADDOP> Lexeme " << yytext <<" found\n" ;
                  token << "<ADDOP, "<<yytext<<">" ; }

{MULOP}   {//cout<<"MULOP==>"<<yytext<<endl; 
              tokenlog << "Line no: "<< linecount<<" TOKEN <MULOP> Lexeme " << yytext <<" found\n" ;
                  token << "<MULOP, "<<yytext<<">";}
{INCOP}   {//cout<<"INOP==>"<<yytext<<endl;
                 tokenlog << "Line no: "<< linecount<<" TOKEN <INOP> Lexeme " << yytext <<" found\n" ;
                  token << "<INCOP, "<<yytext<<">";}

{RELOP}   {//cout<<"RELOP==>"<<yytext<<endl;
                 tokenlog << "Line no: "<< linecount<<" TOKEN <RELOP> Lexeme " << yytext <<" found\n" ;
                  token << "<RELOP, "<<yytext<<">" ;}

{ASSIGNOP}  {//cout<<"ASSINGOP==>"<<yytext<<endl;
                  tokenlog << "Line no: "<< linecount<<" TOKEN <ASSIGNOP> Lexeme " << yytext <<" found\n" ;
                  token << "<ASSIGNOP, "<<yytext<<">";}

{LOGICOP}  {//cout<<"LOGICOP==>"<<yytext<<endl;
           tokenlog << "Line no: "<< linecount<<" TOKEN <LOGICOP> Lexeme " << yytext <<" found\n" ;
                  token << "<LOGICOP, "<<yytext<<">";}

{BITOP}    {//cout<<"BITOP==>"<<yytext<<endl;
                  tokenlog << "Line no: "<< linecount<<" TOKEN <BITOP> Lexeme " << yytext <<" found\n" ;
                  token << "<BITOP, "<<yytext<<">" ;}


"!"     {//cout<<"NOT==>"<<yytext<<endl;
             tokenlog << "Line no: "<< linecount<<" TOKEN <NOT> Lexeme " << yytext <<" found\n" ;
                  token << "<NOT, "<<yytext<<">" ;}
"("      {//cout<<"LPAREN==>"<<yytext<<endl;
               tokenlog << "Line no: "<< linecount<<" TOKEN <LPAREN> Lexeme " << yytext <<" found\n" ;
                  token << "<LPAREN, "<<yytext<<">" ;}
")"       {//cout<<"RPAREN==>"<<yytext<<endl;
               tokenlog << "Line no: "<< linecount<<" TOKEN <RAREN> Lexeme " << yytext <<" found\n" ;
                  token << "<RPAREN, "<<yytext<<">" ;}
"{"        {//cout<<"LCURL==>"<<yytext<<endl;
                  tokenlog << "Line no: "<< linecount<<" TOKEN <LCURL> Lexeme " << yytext <<" found\n" ;
                  token << "<LCURL, "<<yytext<<">" ;}
"}"          {//cout<<"RCURL==>"<<yytext<<endl;
                  tokenlog << "Line no: "<< linecount<<" TOKEN <RCURL> Lexeme " << yytext <<" found\n" ;
                  token << "<RCURL, "<<yytext<<">" ;}
"["         {//cout<<"LTHIRD==>"<<yytext<<endl;
                    tokenlog << "Line no: "<< linecount<<" TOKEN <LTHIRD> Lexeme " << yytext <<" found\n" ;
                  token << "<LTHIRD, "<<yytext<<">" ;}
"]"          {//cout<<"RTHIRD==>"<<yytext<<endl;
                       tokenlog << "Line no: "<< linecount<<" TOKEN <RTHIRD> Lexeme"<<yytext<<"found\n";
                  token << "<RTHIRD, "<<yytext<<">" ;}
","           {//cout<<"COMMA==>"<<yytext<<endl;
                      tokenlog << "Line no: "<< linecount<<" TOKEN <COMMA> Lexeme " << yytext <<" found\n" ;
                  token << "<COMMA, "<<yytext<<">" ;}
";"            {//cout<<"SEMICOLON==>"<<yytext<<endl;
                         tokenlog << "Line no: "<< linecount<<" TOKEN <SEMICOLON> Lexeme " << yytext <<" found\n" ;
                  token << "<SEMICOLON, "<<yytext<<">" ;}




{CHARACTER}     {string ch;
           
               ch=yytext[1];
               tokenlog<<"Line No :"<<linecount<<" Token <CONST_CHAR> Lexeme "<<yytext<<"Found\n"; 
               token<<"<CONST_CHAR,"<<ch<<">";  st.insertscope(yytext,"CONST_CHAR");
                 }

{SLASH}          {errorcount++;
                    tokenlog<<"Error at line : "<<linecount<<" Unterminated character error "<<yytext<<endl;} 

{UNFINCHAR}     { errorcount++;
                  tokenlog<<"Error at line : "<<linecount<<" Unterminated character error "<<yytext<<endl;}

{EMPTYCHAR}     { errorcount++;
                  tokenlog<<"Error at line :"<<linecount<<" Empty character constant error"<<yytext<<endl;}

{MULTCHAR}       {  errorcount++;
                    tokenlog<<"Error at line :"<<linecount<<" Multi character constant error"<<yytext<<endl;}
{UNIQUE}         {
	          tokenlog << "Line No :"<< linecount<<" TOKEN <CONST_CHAR> Lexeme " << yytext <<" found\n" ;
                     string ch1;
                     if(yytext[2]=='n') 
                        {
                        
                          ch1='\n';

			   token << "<CONST_CHAR,\n>"; 
 
                       
                         }
                       else if(yytext[2]=='t') 
                        {
                        
                          ch1='\t'; 
                        
    
                            token << "<CONST_CHAR,\t>" ; 
                         }
                        else if(yytext[2]=='a') 
                        {
                         
                          ch1='\a';
                       
                            token << "<CONST_CHAR,\a>";
                         }

                         else if(yytext[2]=='f') 
                        {
                       
                          ch1='\f';
                     
                            token << "<CONST_CHAR,\f>"; 
                        }

                        else if(yytext[2]=='r') 
                        {
                          
                          ch1='\r';
                      
                            token << "<CONST_CHAR,\r>"; 
                         }

                        else if(yytext[2]=='b') 
                        {
                         cout<<"\b"; 
                          ch1='\b';
                     
                           token << "<CONST_CHAR,\b>"; 
                         }
                         else if(yytext[2]=='v') 
                        {
                         cout<<"\v"; 
                        
                          
                            token << "<CONST_CHAR,\v>" ; 
                         }
                        else if(yytext[2]=='0') 
                        {
                          
                          ch1='\0';
                           token << "<CONST_CHAR,\0>"  ; 
                         }
                         else if(yytext[2]=='\\') 
                        {
                         cout<<"\\"; 
                       
                           token << "<CONST_CHAR,\\>" ; 
                         }
                          else
                        {
                         cout<<"\""; 
                       
                           token << "<CONST_CHAR,\">" ; 
                         }

                       st.insertscope(yytext,"CONST_CHAR");
                      

                     }



{INTEGER}  {
            tokenlog<<"Line no  :"<<linecount<<" Token <INTEGER> Lexeme "<< yytext <<" found\n";
            token<<"<INTEGER,"<<yytext<<">";
              st.insertscope(yytext,"CONST_INT");}  


{FLOAT}         {
                   tokenlog<<"Line no :"<<linecount<<" Token <CONST_FLOAT> Lexeme "<< yytext <<" found\n";
                   token<<"<CONST_FLOAT,"<<yytext<<">";
                      st.insertscope(yytext,"CONST_FLOAT");}


{IllFormFloat} { errorcount++;
                 tokenlog<<"Error at Line :"<<linecount<<" Ill formed  Number  "<<yytext<<endl;}

{TooDecFloat}   {  errorcount++;
                  tokenlog<<"Error at Line :"<<linecount<<" Too many decimal point number  "<<yytext<<endl;}



{ERRID}        {tokenlog<<"Error at Line :"<<linecount<<" Invalid Prefix on ID or Invalid suffix on Number  "<<yytext<<endl; 
                  errorcount++; }                     

{ID}            {tokenlog<<"Line no :"<<linecount<<" Token <ID> Lexeme "<< yytext <<" found\n";
                 token<<"<ID,"<<yytext<<">";
                  st.insertscope(yytext,"ID");} 
            
            

.		{ errorcount++; tokenlog<<"Error at line :"<<linecount<<" Unrecognized character "<<yytext<<"Found"<<endl;} 

%%

int main(int argc, char *argv[])
{       	



           if(argc!=2){
		printf("No file name\n");
		return 0;
	

        }
	
	FILE *f=fopen(argv[1],"r");
	if(f==NULL){
		printf(" can not open file\n");
		return 0;
	}
	


	yyin=f;
       
	yylex();
        tokenlog<<"Total Error :  "<<errorcount<<"\n";
         tokenlog<<"Total Line :  "<<linecount-1<<"\n";
        
       fclose(yyin);
        token.close();
       tokenlog.close();
        //st.printcurrent();
	return 0 ;
}

 

