%{

#include<bits/stdc++.h>
#include<vector>

#include "1505032_symboltable.h"



ofstream filelog("1505032_log1.txt") ; 
extern ofstream fileerror;
ofstream filecode("1505032_code.asm");

using namespace std;

string type_var;
int yyparse(void);
int yylex(void);
extern int linecount;
extern FILE *yyin;
int flag = 1 ;
symboltable *st=new symboltable(7);
symbol *check = new symbol();
int paramnumber;
extern int semerror;
string returntype="";
string globalid="";

vector<string> datavar;
vector<string> dataarr;
vector<int> arrsize;

vector<string>extravar;

int levelcount=0;
int tempcount=0;
int  testcount = 0;
int  maxtemp = 0;

int number=0;
int printfunc=0;

string withoutmain="";

char *testvar()
{
	char *test= new char[4];
	strcpy(test,"test");
	char b[3];
	sprintf(b,"%d",testcount);
	testcount++;
	strcat(test,b);
	return test;
}

char *jumplevel()
{
	
        char *jl= new char[4];
	strcpy(jl,"Level");
	char level[3];
	sprintf(level,"%d",levelcount);
	levelcount++;
	strcat(jl,level);
	return jl;
}

char *tempvar()
{
	char *temp= new char[4];
	strcpy(temp,"temp");
	char b[3];
	sprintf(b,"%d",tempcount);
	tempcount++;
	if(maxtemp < tempcount) 
           {
           maxtemp = tempcount;
           }
	strcat(temp,b);
	return temp;
}



void yyerror(char *s)
{
	
cout << "ERROR OCCURED" << endl ;
//fileerror<<"Error at line : "<<linecount<<"error occured\n\n";
//semerror++;
}


%}


%union { 

symbol *p;
}
%token <p> LPAREN RPAREN SEMICOLON COMMA LCURL RCURL LTHIRD RTHIRD
%token <p> INT FLOAT VOID  FOR IF ELSE RETURN 
%token <p> LOGICOP INCOP DECOP MULOP NOT RELOP ADDOP ASSIGNOP PRINTLN WHILE
%token <p> CONST_INT CONST_FLOAT ID 

%type <p> start program unit var_declaration func_declaration func_definition type_specifier 
%type <p> statement parameter_list expression_statement expression variable logic_expression 
%type <p> rel_expression simple_expression term unary_expression factor argument_list arguments declaration_list
%type <p> statements compound_statement



%nonassoc lower
%nonassoc ELSE



%%

start : program
	{
	   $$ = new symbol() ;
           filelog<<"Line :"<<linecount<<" : start : program\n\n";
           filelog<<$1->line<<"\n\n";
           $$->line=$1->line;
           if(semerror==0)
        {
           filecode<<".model small\n.stack 100h\n\n.data\n\n";
           for(int i=0;i<datavar.size();i++){
		 filelog<<datavar[i] << " dw ?\n";
                  filecode<<datavar[i] << " dw ?\n";			
			}
           for(int i = 0 ; i< dataarr.size() ; i++){
                filelog<< dataarr[i] << " dw " << arrsize[i] << " dup(?)\n";
                filecode<< dataarr[i] << " dw " << arrsize[i] << " dup(?)\n";
			}

            for(int i = 0 ; i< extravar.size() ; i++){
                 filelog<<extravar[i] << " dw ?\n";
                  filecode<<extravar[i] << " dw ?\n";
			}
                 filecode<<"\n.code\n\n";
            //assembly
                      $$->code+=$1->code;
            if(printfunc==1)
               {

              $$->code+="\n\nprintlnfunc proc near\n\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n";
              $$->code+="\tor ax , ax\n\tjge check\n\tpush ax\n \tmov dl,'-'\n\tmov ah , 2\n\tint 21h\n\tpop ax\n\tneg ax\n";
              $$->code+=" check:\n\txor cx,cx\n\tmov bx,10d\n";
              $$->code+=" again:\n\txor dx,dx\n\tdiv bx\n\t push dx\n\tinc cx\n\tor ax,ax\n\tjne again\n\tmov ah,2\n";
              $$->code+=" print:\n\tpop dx\n\tor dl,30h\n\tint 21h\n\tloop print\n";
              $$->code+="\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\nprintlnfunc endp\n";
              }


                      $$->assname=$1->assname;
                    filelog<<$$->code<<"\n";
                    filecode<<$$->code<<"\n";
           }
	}
	;

program : program unit 
           {
            $$ = new symbol() ;
            filelog<<"Line :"<<linecount<<" : program : program unit\n\n";
            filelog<<$1->line<<" "<<$2->line<<"\n\n";
            $$->line=$1->line+$2->line;
             //assembly
                      $$->code=$2->code+$1->code;// changed here
                      $$->assname=$1->assname;
                        filelog<<$$->code<<"\n";

}
	| unit
            {
            filelog<<"Line :"<<linecount<<" : program : unit\n\n";
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
             //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;
                        filelog<<$$->code<<"\n";
           }
	;
	
unit : var_declaration {
            $$ = new symbol() ;filelog<<"Line :"<<linecount<<" : unit : var_declaration\n\n";
       
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
                      }
     | func_declaration{
            $$ = new symbol() ; filelog<<"Line :"<<linecount<<" : unit : func_declaration\n\n";
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
             //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;
                        filelog<<$$->code<<"\n";
              }
                        
     | func_definition{
            $$ = new symbol() ; 
            filelog<<"Line :"<<linecount<<" : unit : func_definition\n\n";
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
             //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;
                      filelog<<$$->code<<"\n";

             }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
              {   $$ = new symbol() ;
                filelog<<"Line :"<<linecount<<" : func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
                filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<"\n\n";
                $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line;
               
                     symbol *searchpoint;

                     searchpoint=st->lookupscope($2->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : multiple declaration of :"<<$2->getname()<<"\n\n";
                          semerror++;
                      }
                      else{
                           symbol* s = st->insertscope($2->getname(),$2->gettype());
	                   s->variabletype=$1->variabletype ; 
                           s->idtype="FUNCTION";
                           s->parametertypelist= $4->parametertypelist;
                           s->variablenamelist= $4->variablenamelist;
                           s->parameterno=paramnumber;
                           //filelog<<"parameter number in declare s "<<s->parameterno<<"\n\n";
                           check=s;
                                  s->assnamelist=$4->assnamelist;
                            //filelog<<"parameter number in declare check "<<check->parameterno<<"\n\n";
                          }
                
                 
                   }
                | type_specifier ID LPAREN parameter_list RPAREN error
              {   $$ = new symbol() ;
                filelog<<"Line :"<<linecount<<" : func_declaration : type_specifier ID LPAREN parameter_list RPAREN error\n\n";
                   fileerror<<"Error at line "<<linecount<<" : missing semicolon"<<"\n\n";
                   semerror++;
                filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
               
                     symbol *searchpoint;

                     searchpoint=st->lookupscope($2->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : multiple declaration of :"<<$2->getname()<<"\n\n";
                          semerror++;
                      }
                      else{
                           symbol* s = st->insertscope($2->getname(),$2->gettype());
	                   s->variabletype=$1->variabletype ; 
                           s->idtype="FUNCTION";
                           s->parametertypelist= $4->parametertypelist;
                           s->variablenamelist= $4->variablenamelist;
                           s->parameterno=paramnumber;
                           check=s;
                          //assembly 
                           s->assnamelist=$4->assnamelist;

                          }
                
                
                   }
               
		| type_specifier ID LPAREN RPAREN SEMICOLON
                 {   
                 $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                    symbol *searchpoint;

                     searchpoint=st->lookupscope($2->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                          fileerror<<"Error at line "<<linecount<<" : multiple declaration of :"<<$2->getname()<<"\n\n";
                           semerror++;
                      }
                      else{
                           symbol* s = st->insertscope($2->getname(),$2->gettype());
	                   s->variabletype=$1->variabletype ; 
                           s->idtype="FUNCTION";
                           s->parameterno=0;
                          // check=s;
                             }
                   }
                  | type_specifier ID LPAREN RPAREN error
                 {   
                 $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : func_declaration : type_specifier ID LPAREN parameter_list RPAREN error\n\n";
                    fileerror<<"Error at line "<<linecount<<" : missing ; "<<"\n\n";
                     semerror++;
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line;
                    symbol *searchpoint;

                     searchpoint=st->lookupscope($2->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                          fileerror<<"Error at line "<<linecount<<" : multiple declaration of "<<$2->getname()<<"\n\n";
                           semerror++;
                      }
                      else{
                           symbol* s = st->insertscope($2->getname(),$2->gettype());
	                   s->variabletype=$1->variabletype ; 
                           s->idtype="FUNCTION";
                           s->parameterno=0;
                         
                             }
                   }
               
		
		;



func_definition : type_specifier ID LPAREN parameter_list RPAREN {
                       int okay=1;
                     
                       
                        symbol *searchpoint;
               
                        searchpoint=st->lookupscope($2->getname());
                        flag=1;
                        //searchpoint->assnamelist=$4->assnamelist;
                      // $2->assnamelist=$4->assnamelist;
                    
                         if(searchpoint==NULL)
                       {
                       symbol* s = st->insertscope($2->getname(),$2->gettype());
	               s->variabletype = $1->variabletype; 
                       s->idtype="FUNCTION";
                       s->parametertypelist= $4->parametertypelist;
                       s->variablenamelist= $4->variablenamelist;
                       s->parameterno=paramnumber;
                       flag = 1 ;
                       
                       returntype=$1->variabletype; 
                       //assembly
                       s->assnamelist=$4->assnamelist;
                       $2->assnamelist=$4->assnamelist;

                      // filelog<<"return type in def "<<returntype<<"\n\n";

                      // filelog<<"vartype rparen "<<$1->variabletype<<"\n\n"; 
                      /*  for(int i=0;i<$4->parametertypelist.size();i++)//print hocche nah
                     {
			 filelog<<$4->variablenamelist[i]<<endl;
                       filelog<<$4->parametertypelist[i]<<endl;
                       
                      }*/
                      /* for(int i=0;i<s->parametertypelist.size();i++)//print hocche nah
                     {
			filelog<<$4->variablenamelist[i]<<endl;
                       filelog<<s->parametertypelist[i]<<endl;
                       
                      }*/
                       
                      }
                        else
                       {  searchpoint->assnamelist=$4->assnamelist;
                          $2->assnamelist=$4->assnamelist; 
                         
                         if($1->variabletype!=searchpoint->variabletype)
                         {
  fileerror<<"Error at line "<<linecount<<" : variable type of function : "<<$2->getname()<<" doesnt match "<<"\n\n";
                         semerror++;
                         }


                          if(check->parameterno!=$4->parameterno) 
                          { 
                            fileerror<<"Error at line "<<linecount<<" : in function : "<<$2->getname()<<" declared parameters and defined parameters number dont match "<<"\n\n";
                            semerror++;
                            flag=0;
                          }
                         else{
                               for(int i=0;i<$4->parametertypelist.size();i++)
                               {
                                if(check->parametertypelist[i]!=$4->parametertypelist[i])
                                {
                                  okay=0;
                                } 
                                if(check->variablenamelist[i]!=""&&check->variablenamelist[i]!=$4->variablenamelist[i])
                                {
                                okay=0;
                                }
                               } 
                             } 
                         
                                if(okay==0)
                                {
                               //filelog<<"PARAMETERS NOT OKAY\n";
  fileerror<<"Error at line "<<linecount<<" : in function "<<$2->getname()<<" declared parameters and defined parameters dont match "<<"\n\n";
                                 semerror++;
                                 flag=0;
                                 }
                               else{  returntype=$1->variabletype; }
                         
		      }
                       globalid=$2->getname();
                         //filelog<<"global id"<<globalid<<"\n";

		   } compound_statement
                  {$$ = new symbol() ;
                 filelog<<"Line :"<<linecount<<" : func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";  
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$7->line;
                   

                    //assembly
                     //assembly
                    

                   
                     if($2->getname()=="main"){

                      $$->code += "\n"+$2->getname() + " PROC NEAR\n\n";
                     //$$->code += "\n"+$2->getname() + " PROC NEAR\n\n"+$4->code;
                    
                    
                        $$->code +=$7->code;
			  $$->code+="\tmov ah,4ch\n\tint 21h\n";
			}
                     else
                       {
                           
                    $$->code += "\n"+$2->getname() + " PROC NEAR\n\n"+"\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n";
                   //$$->code += "\n"+$2->getname() + " PROC NEAR\n\n"+$4->code;
                     for(int i=0;i<$2->assnamelist.size();i++)
                      {
                       $$->code+="\tpush "+$2->assnamelist[i]+"\n";
                      }
                    
                        $$->code +=$7->code;
                         //$$->code+="\tret  "+to_string($4->parameterno*2)+"\n";;
                          $$->code +="Ret"+globalid+":\n";
                        for(int i=$2->assnamelist.size()-1;i>=0;i--)
                      {
                       $$->code+="\tpop "+$2->assnamelist[i]+"\n";
                      }
                    
                          $$->code += "\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\n";
                         $$->code+="\tret\n";;


                       }

		        $$->code += "\n" + $2->getname() + " ENDP\n\n"; 
                    filelog<<$$->code<<"\n";    
                     
                   }
		| type_specifier ID LPAREN RPAREN {

                 returntype=$1->variabletype;// filelog<<"return type in def "<<returntype<<"\n\n";
                  globalid=$2->getname();
                        // filelog<<"global id"<<globalid<<"\n";
                                     }  
                  compound_statement
 		 {$$ = new symbol() ;
                 filelog<<"Line :"<<linecount<<" : func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";  
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$6->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$6->line;
                    // st.insertscope($2->getname(),$2->gettype());
                       symbol *searchpoint;

                        searchpoint=st->lookupscope($2->getname());
                         if(searchpoint==NULL)
                         {
                          symbol* s = st->insertscope($2->getname(),$2->gettype());
	                  s->variabletype = $1->variabletype; 
                          s->idtype="FUNCTION";
                          s->parameterno=0;
                         // returntype=$1->variabletype;
                         
                        }
                        else {
                             if($1->variabletype!=searchpoint->variabletype)
                         {
  fileerror<<"Error at line "<<linecount<<" : variable tupe of function : "<<$2->getname()<<" doesnt match "<<"\n\n";
                          semerror++;
                             }
                              if(searchpoint->parameterno!=0)
                               {
 fileerror<<"Error at line "<<linecount<<" : in function "<<$2->getname()<<" declared parameters and defined parameters dont match "<<"\n\n";
                                 semerror++;
                               }
                      //filelog<<"return type in def "<<returntype<<"\n\n";
                     } 
                     //assembly
                     // $$->code += "\n"+$2->getname() + " PROC NEAR\n\n";
                     
                    if($2->getname()=="main"){

                          $$->code += "\n"+$2->getname() + " PROC NEAR\n\n";
                     
                          $$->code+="\tmov ax,@data\n\tmov ds,ax\n";
			 // $$->code+="\tmov ah,4ch\n\tint 21h\n";
			
                      
                             $$->code+=$6->code;
                      
			  $$->code+="\tmov ah,4ch\n\tint 21h\n";
			}
                     else
                       {  $$->code += "\n"+$2->getname() + " PROC NEAR\n\n"+"\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n";
                         //$$->code+="\tret  "+to_string($4->parameterno*2)+"\n";;
                             $$->code+=$6->code;
                          $$->code +="Ret"+globalid+":\n";
                           $$->code += "\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n";
                         $$->code+="\tret\n";;


                       }

		        $$->code += "\n" + $2->getname() + " ENDP\n\n"; 
                    filelog<<$$->code<<"\n";    
			
                 }
                ;				


parameter_list  : parameter_list COMMA type_specifier ID
                 {
                  $$ = new symbol() ; 
                 filelog<<"Line :"<<linecount<<" : parameter_list  : parameter_list COMMA type_specifier ID\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line;
                    cout<<"type and name==> "<<$3->variabletype<<" "<<$4->getname()<<"\n\n";
                   $$->parametertypelist=$1->parametertypelist;  
		   $$->variablenamelist=$1->variablenamelist ; 
                   $4->idtype="VARIABLE";
                   $4->variabletype=$3->variabletype;
                  $$->parametertypelist.push_back($3->variabletype);
                  $$->variablenamelist.push_back($4->getname());
                   
                    paramnumber++;
                  $$->parameterno=paramnumber;


                  //assembly
                         $$->assnamelist=$1->assnamelist ;
                           $4->assname=$4->getname()+to_string(st->m+1)+to_string(number);
                           number++;;
                           datavar.push_back($4->assname);
                        $$->assnamelist.push_back($4->assname);
                  
                   //$$->code="\tpop ax\n";
                   //$$->code+="\tmov "+$4->assname+" ,ax\n";
                    $$->code+=$1->code;
                    filelog<<$$->code<<"\n";

                    //filelog<<"parameter number "<<paramnumber<<"\n\n";
                  }
		| parameter_list COMMA type_specifier
                { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : parameter_list  : parameter_list COMMA type_specifier\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line;
                    cout<<"type and name==> "<<$3->variabletype<<" "<<"faka"<<"\n\n";
                   $$->parametertypelist=$1->parametertypelist;  
		      $$->variablenamelist=$1->variablenamelist;  
                   $$->parametertypelist.push_back($3->variabletype);
                   $$->variablenamelist.push_back("");
                   paramnumber++;
                      $$->parameterno=paramnumber;

                     $$->assnamelist=$1->assnamelist ;
                  // filelog<<"parameter number "<<paramnumber<<"\n\n";
                 }
 		| type_specifier ID
                { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : parameter_list  : type_specifier ID\n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                   cout<<"type and name==> "<<$1->variabletype<<" "<<$2->getname()<<"\n\n";
                   $2->idtype="VARIABLE";
                   $2->variabletype=$1->variabletype;
                   $$->parametertypelist.push_back($1->variabletype);
                   $$->variablenamelist.push_back($2->getname()); 
                   paramnumber=1;
                      $$->parameterno=paramnumber;
                    //assembly
              
                           $2->assname=$2->getname()+to_string(st->m+1)+to_string(number);
                           number++;;
                           datavar.push_back($2->assname);
                            $$->assnamelist.push_back($2->assname);
                        //  $$->code+="\tpop ax\n";
                        //  $$->code+="\tmov "+$2->assname+" ,ax\n";
                           filelog<<$$->code<<"\n";


                 }
		| type_specifier
                 { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : parameter_list  : type_specifier\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                   cout<<"type and name==> "<<$1->variabletype<<" "<<"faka"<<"\n\n";
                   $$->parametertypelist.push_back($1->variabletype);
                   $$->variablenamelist.push_back("");
                   paramnumber=1;
                   $$->parameterno=paramnumber;
                   
                 }
 		;

 		
compound_statement : LCURL {st->enterscope(filelog);
                    /* filelog<<"hello";
                     for(int i=0;i<$<p>-2->parametertypelist.size();i++)//print hocche nah
                     {
			
                       filelog<<$<p>-2->parametertypelist[i]<<endl;
                       
                      }*/
                    if(flag==1)
                     {
                      for(int i=0;i<$<p>-2->parametertypelist.size();i++)
                      {
			//cout<<"bhikkkkk\n\n";
                       cout<<$<p>-2->parametertypelist[i]<<endl;
                       if($<p>-2->variablenamelist[i]!="")
                          {
                          symbol *s=st->insertscope($<p>-2->variablenamelist[i],"ID");
                          s->variabletype =$<p>-2->parametertypelist[i] ; 
                          s->idtype="ID";
                          //assembly
                            s->assname=$<p>-2->assnamelist[i] ;
                           
                          //s->assname=$<p>-2->assnamelist[i] ;
                          filelog<<"assname in compound"<<s->assname<<"\n\n";
                          }
                       
                       }

                      }
                      /* for(int i=0;i<$<p>-2->assnamelist.size();i++)
                      {
			filelog<<"assnames"<<$<p>-2->assnamelist[i]<<endl;
                     }*/

                      } statements{st->printcurrent(filelog);} RCURL{st->exitscope(filelog);}
 
                    { $$ = new symbol() ;
                     filelog<<"Line :"<<linecount<<" : compound_statement : LCURL statements RCURL\n\n";
                     filelog<<$1->line<<" "<<$3->line<<" "<<$5->line<<"\n\n";
                      $$->line=$1->line+$3->line+$5->line;

                       //assembly
                    $$->code=$3->code;
                    filelog<<$$->code<<"\n";
                  
                    }
 		    | LCURL RCURL
                    { $$ = new symbol() ;
                     filelog<<"Line :"<<linecount<<" : compound_statement : LCURL RCURL\n\n";
                   filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
                  { $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : var_declaration : type_specifier declaration_list SEMICOLON\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line;
                  }
                 |type_specifier declaration_list error
                  { $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : var_declaration : type_specifier declaration_list error\n\n";
                   filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                   fileerror<<"Error at Line :" << linecount<<" missing semicolon" << endl <<endl ;
                    semerror++; 
                  }
                
 		 ;
 		 
type_specifier	: INT 
                 { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : type_specifier : INT\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  
                  type_var="INT";
                  $$=$1;
                  $$->variabletype="INT";
                  

                 }
 		| FLOAT
                 { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : type_specifier : FLOAT\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  
                  type_var="FLOAT";
                  $$=$1;
                  $$->variabletype="FLOAT";
                  }
 		| VOID
                 
                 { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : type_specifier : VOID\n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                  
                   type_var="VOID";
                   $$=$1;
                   $$->variabletype="VOID";
                 }
 		;
 		
declaration_list : declaration_list COMMA ID
                   {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : declaration_list : declaration_list COMMA ID\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line;
                   
                   if(type_var=="VOID")
                    {
                    fileerror<<"Error at line "<<linecount<<" : type of variable can not be void\n\n";
                     semerror++;
                    }	
                   else
                   {
                       symbol *searchpoint;

                       searchpoint=st->lookupscope1($3->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                        fileerror<<"Error at line "<<linecount<<" : multiple declaration of : "<<$3->getname()<<"\n\n";
                          semerror++;
                      }
                      else{
                           symbol *s;
                           s=st->insertscope($3->getname(),$3->gettype());
                           s->idtype="VARIABLE";
                           s->variabletype=type_var;
                           s->line=$3->line;
                            // filelog<<"onkbar\n";
                           s->assname=$3->getname()+to_string(st->m)+to_string(number);
                           number++;;
                           datavar.push_back(s->assname);
                          
                             }
                   }
                   
                 }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
                   {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line;
                    if(type_var=="VOID")
                    {
                        fileerror<<"Error at line "<<linecount<<" : type of variable can not be void\n\n";
                         semerror++;
                    }	
                   else
                   {
                       symbol *searchpoint;

                       searchpoint=st->lookupscope1($3->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                        fileerror<<"Error at line "<<linecount<<" : multiple declaration of :"<<$3->getname()<<"\n\n";
                          semerror++;
                      }
                      else{
                           symbol *s;
                           s=st->insertscope($3->getname(),$3->gettype());
                           s->idtype="ARRAY";
                           s->arraysize=stoi($5->getname());
                           s->variabletype=type_var;
                           s->line=$3->line;
                         //assembly
                           s->assname=$3->getname()+to_string(st->m)+to_string(number);
                           number++;
                           dataarr.push_back(s->assname);
		           arrsize.push_back(s->arraysize);
                             }
                   }
                 
                 }
 		  | ID
                  {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : declaration_list : ID\n\n";
                  filelog<<$1->getname()<<"\n\n";
                   $$->line=$1->line;
                   if(type_var=="VOID")
                    {
                    fileerror<<"Error at line "<<linecount<<" : type of variable can not be void\n\n";
                     semerror++;
                    }	
                   else
                   {
                       symbol *searchpoint;

                       searchpoint=st->lookupscope1($1->getname());

                      if(searchpoint!=NULL)
                      {
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : multiple declaration of  :"<<$1->getname()<<"\n\n";
                          semerror++;
                         
                      }
                      else{
                           symbol *s;
                           s=st->insertscope($1->getname(),$1->gettype());
                           s->idtype="VARIABLE";
                           s->variabletype=type_var;
                           s->line=$1->line;
                          
                          //assembly
                          // filelog<<"onkbar\n";
                           s->assname=$1->getname()+to_string(st->m)+to_string(number);
                           number++;
                           $$=s;
                           datavar.push_back(s->assname);
                             }
                    }


                  
                 }
                  
 		  | ID LTHIRD CONST_INT RTHIRD
                     {
                    $$ = new symbol() ;
                    filelog<<"Line :"<<linecount<<" : declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                    //$$->line=$1->line+$2->line+$3->line+$4->line;
                  
                     if(type_var=="VOID")
                    {
                    fileerror<<"Error at line "<<linecount<<" : type of variable can not be void\n\n";
                     semerror++;
                    }	
                   else
                   {
                       symbol *searchpoint;

                       searchpoint=st->lookupscope1($1->getname());

                      if(searchpoint!=NULL)
                      {  
                         cout<<"name is: "<<$1->getname();
                         cout<<"\nAlready exist in current scope table\n";
                         filelog<<"Already exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : multiple declaration of  : "<<$1->getname()<<"\n\n";
                          semerror++;
                      }
                      else{
                           symbol *s;
                           s=st->insertscope($1->getname(),$1->gettype());
                           s->idtype="ARRAY";
                           s->arraysize=stoi($3->getname());
                           s->variabletype=type_var;
                           //s->line=$1->line;
                           //assembly
                           s->assname=$1->getname()+to_string(st->m)+to_string(number);
                           number++;
                           $$=s;
                          
                           
                           dataarr.push_back(s->assname);
		           arrsize.push_back(s->arraysize);
                             }
                    }
                     

                     $$->line=$1->line+$2->line+$3->line+$4->line;
                    }
 		  ;
 		  
statements : statement
               {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statements : statement\n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                    //assembly
                      $$->code=$1->code;
                      filelog<<$$->code<<"\n";
                   
                }
	   | statements statement
               {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statements : statements statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                    //assembly
                      $$->code=$1->code+$2->code; //adding codes
                        filelog<<$$->code<<"\n";
                  
               }
	   ;
	   
statement : var_declaration
              {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statement : var_declaration\n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                   
                 }
	  | expression_statement
             {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statement : expression_statement\n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                    //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;


                    filelog<<$$->code<<"\n";
                 }
	  | compound_statement
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : compound_statement\n\n";
                  filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                    //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;
                    filelog<<$$->code<<"\n";
                  
                 }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
            {
                   $$ = new symbol() ;
          filelog<<"Line :"<<linecount<<" : statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line+$7->line;


            	     //assembly
                     $$->code=$3->code;
                     $$->assname=$3->assname;
		     char *label1 =jumplevel();
		     char *label2 =jumplevel();
		     $$->code += string(label1) + ":\n";
		     $$->code+=$4->code;
		     $$->code+="\tmov ax , "+$4->assname+"\n";
		     $$->code+="\tcmp ax , 0\n";
		     $$->code+="\tje "+string(label2)+"\n";
		     $$->code+=$7->code;
		     $$->code+=$5->code;
		     $$->code+="\tjmp "+string(label1)+"\n";
		      $$->code+=string(label2)+":\n";

                      }
	  | IF LPAREN expression RPAREN statement  %prec lower
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : IF LPAREN expression RPAREN statement\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                   //assembly
                   $$->code=$3->code;//code assign

                  $$->assname=$3->assname;

                   char *label=jumplevel();
		    $$->code+="\tmov ax, "+$3->assname+"\n";
		    $$->code+="\tcmp ax, 0\n";
		    $$->code+="\tje "+string(label)+"\n";
		    $$->code+=$5->code;
		    $$->code+=string(label)+":\n";
					
		    //$$->setName("if");//not necessary
                    filelog<<$$->code<<"\n";
                    filelog<<$$->assname<<"\n";
                      


                 }
	  | IF LPAREN expression RPAREN statement ELSE statement
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line+$7->line;
                 //assembly
                   $$->code=$3->code;//code assign

                   $$->assname=$3->assname;
		  char *elselabel=jumplevel();
	          char *exitlabel=jumplevel();
		   $$->code+="\tmov ax,"+$3->assname+"\n";
		   $$->code+="\tcmp ax,0\n";
		   $$->code+="\tje "+string(elselabel)+"\n";
		   $$->code+=$5->code;
		   $$->code+="\tjmp "+string(exitlabel)+"\n";
		   $$->code+=string(elselabel)+":\n";
		   $$->code+=$7->code;
		   $$->code+=string(exitlabel)+":\n";

                      

                      //$$->setName("if");//not necessary
                    filelog<<$$->code<<"\n";
                    //filelog<<$$->assname<<"\n";
                 }
	  | WHILE LPAREN expression RPAREN statement
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : WHILE LPAREN expression RPAREN statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                  
                 //assembly
                 
		 char * label = jumplevel();
	         char * exit =  jumplevel();
		 $$->code = string(label) + ":\n"; 
		 $$->code+=$3->code;
		 $$->code+="\tmov ax , "+$3->assname+"\n";
		 $$->code+="\tcmp ax , 0\n";
		 $$->code+="\tje "+string(exit)+"\n";
		 $$->code+=$5->code;
		 $$->code+="\tjmp "+string(label)+"\n";
		 $$->code+=string(exit)+":\n";
                



              }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                   symbol *s;

                       s=st->lookupscope($3->getname());

                      if(s==NULL)
                      {
                        
                         fileerror<<"Error at line "<<linecount<<" :does not exist this ID :"<<$3->getname()<<"\n\n";
                          semerror++;
                         
                      }

                      $$->code += "\tmov ax, " + s->assname +"\n";
		      $$->code += "\tcall printlnfunc\n";
                      printfunc=1;


                }
          | PRINTLN LPAREN ID RPAREN error
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : PRINTLN LPAREN ID RPAREN error\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line;
                      symbol *s;
                     s=st->lookupscope($3->getname());

                      if(s==NULL)
                      {
                        
                         fileerror<<"Error at line "<<linecount<<" :does not exist this ID :"<<$3->getname()<<"\n\n";
                          semerror++;
                         
                      }
              }
	  | RETURN expression SEMICOLON
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : RETURN expression SEMICOLON\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line;

                   // filelog<<"return type func " <<returntype<< " expression "<<$2->variabletype<<"\n\n"; 
                    if(returntype!=$2->variabletype)
                {
                 fileerror<<"Error at Line :" << linecount<<" return type does not match" << endl <<endl ; 
                   semerror++;
              } 
               //assembly
               if(globalid!="main")
               {
               //filelog<<"global id==>"<<globalid<<"\n";
               $$->code="\tmov bp,"+$2->assname+"\n";
               $$->code +="\tjmp  Ret"+globalid+"\n";
               }
               filelog<<$$->code<<"\n";

                 }
          | RETURN expression error
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : RETURN expression error\n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                   fileerror<<"Error at Line " << linecount<<" : missing semicolon" << endl <<endl ; 
                   semerror++;
                  if(returntype!=$2->variabletype)
                {
                 fileerror<<"Error at Line " << linecount<<" : return type do not match" << endl <<endl ; 
                   semerror++;
              }   }
          | error SEMICOLON
           {

                fileerror<<"Error at Line " << linecount<<" : error occured" << endl <<endl ; 
                   semerror++;
               }
	  ;
	  
expression_statement 	: SEMICOLON
                        {
                    $$ = new symbol() ;
                    filelog<<"Line :"<<linecount<<" : expression_statement : SEMICOLON\n\n";
                    filelog<<$1->line<<"\n\n";
                    $$->line=$1->line; 
                          }			
			| expression SEMICOLON
                       {
                     $$ = new symbol() ;
                     filelog<<"Line :"<<linecount<<" :expression_statement : expression SEMICOLON\n\n";
                     filelog<<$1->line<<" "<<$2->line<<"\n\n";
                     $$->line=$1->line+$2->line;
                     //assembly
                      $$->code=$1->code;
                      $$->assname=$1->assname;
                        } 
			| expression error
		   	{
                     $$ = new symbol() ;  
                     filelog<<"Line :"<<linecount<<" :expression_statement : expression error\n\n";
                     filelog<<$1->line<<"\n\n";
                     $$->line=$1->line;
                     fileerror<<"Error at Line " << linecount<<" : missing semicolon" << endl <<endl ; 
			}
                        
							
			;
	  
variable : ID 
           {      $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : variable : ID\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                   
                   symbol *s;
                   s=st->lookupscope($1->getname());
                   //filelog<<"assembly name "<<s->assname<<"\n";

                      if(s==NULL)
                      {
                         filelog<<"variable not declared\n\n";
                         fileerror<<"Error at line "<<linecount<<" : variable "<<$1->getname()<<" not declared "<<"\n\n";
                          semerror++;
                      }
                      else{
                       s->line=$1->line;
                         if(s->idtype=="ARRAY") 
                         {
                          fileerror<<"Error at line "<<linecount<<" : array "<<$1->getname()<<" with no index "<<"\n\n";
                           semerror++;
                         }
                         else if(s->idtype=="FUNCTION") 
                         {
                        fileerror<<"Error at line "<<linecount<<" : function "<<$1->getname()<<"  referenced as variable with value "<<"\n\n";
                           semerror++;
                         }
                          else if(s->variabletype=="VOID")
                         {
                          fileerror<<"Error at line "<<linecount<<" : function "<<$1->getname()<<" referenced as variable "<<"\n\n";
                           semerror++;
                         }
                         else
                         {
                          
                           $1=s; 
                           $$=s;
                           $$->line=$1->line;
                           filelog<<$$->assname<<"\n"; //assembly name passing
                           }
                      cout<<"variable type :"<<$1->variabletype<<" "<<$1->idtype<<"\n\n";
                      }
               
                 }			
	 | ID LTHIRD expression RTHIRD
           {      $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : variable : ID LTHIRD expression RTHIRD\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line+$4->line;
                        
                        if($3->variabletype!="INT")
                        {
                         fileerror<<"Error at line "<<linecount<<" array index must be int"<<"\n\n";
                         semerror++;
                        }
                        symbol *s;
                        s=st->lookupscope($1->getname());
                         if(s==NULL)
                        {
                         filelog<<"variable not declared\n\n";
                         fileerror<<"Error at line "<<linecount<<" : variable :"<<$1->getname()<<" not declared "<<"\n\n";
                          semerror++;
                        }
                    else {
                        if(s->idtype=="VARIABLE") 
                         {
                          fileerror<<"Error at line "<<linecount<<" : variable :"<<$1->getname()<<" with index "<<"\n\n";
                           semerror++;
                         }
                         if(s->idtype=="FUNCTION") 
                         {
                          fileerror<<"Error at line "<<linecount<<" : function :"<<$1->getname()<<" with index "<<"\n\n";
                           semerror++;
                         }
                      
                          if(s->idtype=="ARRAY")
                         {
                         s->line=$1->line;
                         $1=s; 
                         $$->variabletype=$1->variabletype;
                         $$->idtype=$1->idtype;
                      
                         cout<<"variable type :"<<$1->variabletype<<" "<<$1->idtype<<"\n\n";
                        }
                     }

                      //assembly
                      $$->code=$3->code ;
		      $$->code += "\tmov bx, " +$3->assname +"\n";
		      $$->code += "\tadd bx, bx\n";
                      $$->assname=$1->assname;
                      filelog<<$$->code<<"helloo\n";


            }	 
	 ;
	 
expression : logic_expression
             	 {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : expression : logic_expression\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                  //assembly
                  $$->assname=$1->assname;
                  $$->code=$1->code;
                  filelog<<$$->code<<"\n";



}
	   | variable ASSIGNOP logic_expression
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : expression : variable ASSIGNOP logic_expression\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                 //filelog<<"function "<<$3->getname()<<" "<<$3->variabletype<<" "<<$3->idtype<<"\n\n"; 
                 //filelog<<" left side type ==> "<<$1->variabletype<<" "<<$1->idtype<<"\n\n";
                 // filelog<<"right side type ==> "<<$3->variabletype<<" "<<$3->idtype<<"\n\n";
                   

                   if($1->variabletype=="INT")
                    {// filelog<<"error1 \n\n";
                     if($3->variabletype=="FLOAT")
                      {//filelog<<"error2 \n\n";
                       fileerror<<"Error at line "<<linecount<<" : Type mismatch "<<"\n\n";
                       semerror++;
                       }
                      else if($3->variabletype=="VOID")
                      {
                       fileerror<<"Error at line "<<linecount<<" :  void function right hand side \n\n";
                        semerror++;
                       }
                       else{ $$->variabletype="INT";}
                     }
                    if($1->variabletype=="FLOAT")
                    { // filelog<<"error3\n\n";
                       if($3->variabletype=="INT")
                       {
                       //filelog<<"error4 \n\n";
                       fileerror<<"Error at line "<<linecount<<" : Type mismatch "<<"\n\n";
                        semerror++;
                        }
                       else if($3->variabletype=="VOID")
                       {
                       fileerror<<"Error at line "<<linecount<<" : void function right hand side\n\n";
                        semerror++;
                        }
                         else{ $$->variabletype="FLOAT";}
                     } 
                     if($1->variabletype=="VOID")
                       {
                       fileerror<<"Error at line "<<linecount<<" : void function left hand side\n\n";
                        semerror++;
                        
                      if($3->variabletype=="VOID")
                       {
                       fileerror<<"Error at line "<<linecount<<" : void function right hand side\n\n";
                        semerror++;
                        }
                      }

                  //assembly
                   $$->code=$3->code+$1->code;
                     //$$->code=$3->code;
		    $$->code+="\tmov ax, "+$3->assname+"\n";
		   if($1->idtype!="ARRAY"){ 
			      $$->code+= "\tmov "+$1->assname+", ax\n";
				}
				
			      else{
			        $$->code+= "\tmov  "+$1->assname+"[bx],ax\n";
				}
                     
             //extra
                    
                    $$->assname=$1->assname;
                
                  filelog<<$$->code<<"\n";
               } 	
	   ;
			
logic_expression : rel_expression 
                   {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : logic_expression : rel_expression \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;

                   //assembly
                  
                  $$->assname=$1->assname;
                  $$->code=$1->code;
                  filelog<<$$->code<<"\n";
            

                 // filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                   } 	
	   	
		 | rel_expression LOGICOP rel_expression 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : logic_expression : rel_expression LOGICOP rel_expression \n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                   if($1->variabletype=="FLOAT"||$3->variabletype=="FLOAT")
                   {
                     fileerror<<"Error at line "<<linecount<<" : variable type is  float \n\n";
                     semerror++;
                    } 
                   if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                   {
                      fileerror<<"Error at line "<<linecount<<" : variable type of function  is void\n\n";
                      semerror++;
                   }
                  $$->variabletype="INT";
                  //assembly
                 $$->code=$1->code+$3->code;
                  char * temp = testvar();
		  char * label1 = jumplevel();
	          char * label2 = jumplevel();
	
		 if($2->getname()=="&&")

                  {
						
		 $$->code += "\tmov ax , " + $1->assname +"\n";
	         $$->code += "\tcmp ax , 0\n";
		 $$->code += "\tje " + string(label1) +"\n";
	         $$->code += "\tmov ax , " + $3->assname+"\n";
		 $$->code += "\tcmp ax , 0\n";
		$$->code += "\tje " + string(label1) +"\n";
		$$->code += "\tmov " + string(temp) + " , 1\n";
	        $$->code += "\tjmp " + string(label2) + "\n";
		$$->code += string(label1) + ":\n" ;
		$$->code += "\tmov " + string(temp) + ", 0\n";
		$$->code += string(label2) + ":\n";
		$$->assname=string(temp);
                //variable pushing
                extravar.push_back(string(temp));
               
			
						
		}
	        else if($2->getname()=="||")

               {
		$$->code += "\tmov ax , " + $1->assname +"\n";
		$$->code += "\tcmp ax , 0\n";
		$$->code += "\tjne " + string(label1) +"\n";
		$$->code += "\tmov ax , " + $3->assname+"\n";
		$$->code += "\tcmp ax , 0\n";
		$$->code += "\tjne " + string(label1) +"\n";
		$$->code += "\tmov " + string(temp) + " , 0\n";
		$$->code += "\tjmp " + string(label2) + "\n";
		$$->code += string(label1) + ":\n" ;
		$$->code += "\tmov " + string(temp) + ", 1\n";
		$$->code += string(label2) + ":\n";
		$$->assname=string(temp);
                //variable pushing
                 extravar.push_back(string(temp));
               
						
	      }
               filelog<<$$->code<<"\n";
                  } 	
		 ;
			
rel_expression	: simple_expression 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : simple_expression \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                
                 //assembly
                 $$->assname=$1->assname;
                 $$->code=$1->code;
                 filelog<<$$->code<<"\n";
                   
                 // filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                  } 
		| simple_expression RELOP simple_expression
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : simple_expression RELOP simple_expression\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                 /* if($1->variabletype=="FLOAT"||$3->variabletype=="FLOAT")
                   {
                     fileerror<<"Error at line "<<linecount<<" : variable type is  float \n\n";
                     semerror++;
                    } */
                   if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                   {
                      fileerror<<"Error at line "<<linecount<<" : variable type of function  is void\n\n";
                      semerror++;
                   }

                  $$->variabletype="INT";
                      //assembly
                        $$->code=$1->code+$3->code;
				$$->code+="\tmov ax, " + $1->assname+"\n";
				$$->code+="\tcmp ax, " + $3->assname+"\n";
				char *temp=testvar();
				char *label1=jumplevel();
				char *label2=jumplevel();
				if($2->getname()=="<"){
					$$->code+="\tjl " + string(label1)+"\n";
				}
				else if($2->getname()=="<="){
					$$->code+="\tjle " + string(label1)+"\n";
				}
				else if($2->getname()==">"){
					$$->code+="\tjg " + string(label1)+"\n";
				}
				else if($2->getname()==">="){
					$$->code+="\tjge " + string(label1)+"\n";
				}
				else if($2->getname()=="=="){
					$$->code+="\tje " + string(label1)+"\n";
				}
				else if($2->getname()=="!="){
					$$->code+="\tjne " + string(label1)+"\n";
				}
				
				$$->code+="\tmov "+string(temp) +", 0\n";
				$$->code+="\tjmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\n";
				$$->code+= "\tmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->assname=string(temp);

                               //variable pushing
                           extravar.push_back(string(temp));
                        

                             filelog<<$$->code<<"\n";
                  } 	
		;
				
simple_expression : term 
                   { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : simple_expression : term \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                
                  $$=$1;

                  $$->assname=$1->assname;
                 // filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                   } 
		  | simple_expression ADDOP term 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : simple_expression : simple_expression ADDOP term  \n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                    $$->line=$1->line+$2->line+$3->line;
                 
                   if(($1->variabletype=="FLOAT"&&$3->variabletype=="INT")||($1->variabletype=="INT"&&$3->variabletype=="FLOAT"))
                   {
                       $$->variabletype="FLOAT";
                    } 
                    if($1->variabletype=="INT"&&$3->variabletype=="INT")
                   {
                    $$->variabletype="INT";
                    }
                       if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                           {
                      fileerror<<"Error at line "<<linecount<<" : variable type of function is void  \n\n";
                     semerror++;
                       }    
                     //assembly
                     $$->code=$1->code+$3->code;
                     if($2->getname()=="+"){
					char* temp = tempvar();
					$$->code += "\tmov ax, " + $1->assname + "\n";
					$$->code += "\tadd ax, " + $3->assname+ "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->assname=string(temp);

                                         //variable pushing
                                          extravar.push_back(string(temp));
               

				}
		     else if($2->getname() == "-"){
					char* temp = tempvar();
					$$->code += "\tmov ax, " + $1->assname+ "\n";
					$$->code += "\tsub ax, " + $3->assname+ "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->assname=string(temp);
                                           //variable pushing
                                         extravar.push_back(string(temp));
                 
				}
                     filelog<<$$->code<<"\n";
                 } 
		  ;
					
term :	unary_expression
            {     $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : term : unary_expression\n\n";
                  $$=$1;
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                 //assembly
                  $$->assname=$1->assname;
                  $$->code=$1->code;
                  filelog<<$$->code<<"\n";
                  //$$->assname=$1->assname;
                 // filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
            } 
     |  term MULOP unary_expression
           {      $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : term : term MULOP unary_expression\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                 //filelog<<"function "<<$1->getname()<<" "<<$1->variabletype<<" "<<$1->idtype<<"\n\n";
                 //filelog<<"function "<<$3->getname()<<" "<<$3->variabletype<<" "<<$3->idtype<<"\n\n";
                 //filelog<<"hello"<<$2->getname()<<"\n\n";
                  if($2->getname()=="*")
                      {
                       // filelog<<"enter\n\n";
                           if(($1->variabletype=="FLOAT"&&$3->variabletype=="INT")||($1->variabletype=="INT"&&$3->variabletype=="FLOAT"))
                           {
                            $$->variabletype="FLOAT";
                           }
                           if($1->variabletype=="INT"&&$3->variabletype=="INT")
                            {
                            $$->variabletype="INT";
                            }
                            if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                           {
                      fileerror<<"Error at line "<<linecount<<" : variable type of function is void mulop\n\n";
                     semerror++;
                           }
                       }
                   if($2->getname()=="/")
                      {
                           if($1->variabletype=="FLOAT"||$3->variabletype=="FLOAT")
                           {
                            $$->variabletype="FLOAT";
                           }
                           if($1->variabletype=="INT"&&$3->variabletype=="INT")
                            {
                            $$->variabletype="INT";
                            }
                          if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                           {
                            fileerror<<"Error at line "<<linecount<<" : variable type of function  is void mulop\n\n";
                     semerror++;
                           }
                            
                       }
                     if($2->getname()=="%")
                      {
                           if($1->variabletype=="FLOAT"||$3->variabletype=="FLOAT")
                           {
                            fileerror<<"Error at line "<<linecount<<" : both operands type should be int for % \n\n";
                            semerror++;}
                            if($1->variabletype=="INT"&&$3->variabletype=="INT")
                            {
                            $$->variabletype="INT";
                            }
                             if($1->variabletype=="VOID"||$3->variabletype=="VOID")
                           {
                      fileerror<<"Error at line "<<linecount<<" : variable type of function  is void mulop \n\n";
                     semerror++;
                           }
                       }
                   //assembly
                   $$->code = $1->code+$3->code;
			$$->code += "\tmov ax, "+ $1->assname+"\n";
			$$->code += "\tmov bx, "+ $3->assname +"\n";
			char *temp=tempvar();
			if($2->getname()=="*"){
				$$->code += "\tmul bx\n";
				$$->code += "\tmov "+ string(temp) + ", ax\n";
                                //variable pushing
                                         extravar.push_back(string(temp));
			}
			else if($2->getname()=="/"){
				
				$$->code += "\txor dx,dx\n";
				$$->code += "\tdiv bx\n";
				$$->code += "\tmov " + string(temp) + " , ax\n";
                                 //variable pushing
                                         extravar.push_back(string(temp));
			}
			else{
			
				$$->code += "\txor dx,dx\n";
				$$->code += "\tdiv bx\n";
				$$->code += "\tmov " + string(temp) + " , dx\n";
                                 //variable pushing
                                         extravar.push_back(string(temp));
				
			}
			$$->assname=string(temp);

 
              }
     ;

unary_expression : ADDOP unary_expression 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : ADDOP unary_expression \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                   $$->variabletype=$2->variabletype;
                  //assembly
                   $$->assname=$2->assname;
                   if($1->getname() == "+"){
				//$$=$2;
                           //assembly
                 
                  $$->code=$2->code;
                  filelog<<$$->code<<"\n";
		   }
		   else if($1->getname() == "-")
		  {
                   $$->code += "\tmov ax, " + $2->assname+ "\n";
		   $$->code += "\tneg ax\n";
		   $$->code += "\tmov " + $2->assname+ " , ax\n";
                   filelog<<$$->code<<"\n";
                  }


                  }  
		 | NOT unary_expression 
                  {$$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : NOT unary_expression \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$2->variabletype;

                  //assembly
                  //  $$->assname=$2->assname;
                    char *temp=tempvar();
                  $$->code+="\tmov ax, " + $2->assname+ "\n";
	          $$->code+="\tnot ax\n";
		  $$->code+="\tmov "+string(temp)+", ax";
                  //$$->code+="\tmov "+$2->assname+", ax";
                  $$->assname=string(temp);
                  extravar.push_back(string(temp));

                  filelog<<$$->code<<"\n";

                 

                  } 
		 | factor
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : factor \n\n";
                  filelog<<$1->line<<"\n\n";
                  
                  
                 //filelog<<"function "<<$1->getname()<<" "<<$1->variabletype<<" "<<$1->idtype<<"\n\n"; 
              
                  $$=$1;
                     //assembly
                    $$->assname=$1->assname;
                    $$->code=$1->code;
                 //filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                  } 
		 ;
	
factor	: variable 
            {     $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: variable \n\n";
                   $$=$1;
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                    $$->assname=$1->assname;
                  //$$=$1;
             }  
	| ID LPAREN argument_list RPAREN 
            {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: ID LPAREN argument_list RPAREN \n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line;
                  
                      symbol *s;

                      s=st->lookupscope($1->getname());
                      int f=1;

                      if(s==NULL)
                      {  
                         
                         filelog<<"does not exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : does not exist this function : "<<$1->getname()<<"\n\n";
                          semerror++; f=0;
                      }
                      else{
                        //  filelog<<"function "<<s->getname()<<" "<<s->variabletype<<" "<<s->idtype<<"\n\n";
                          $1->variabletype=s->variabletype;
                          $1->idtype=s->idtype;
                          $1->parameterno=s->parameterno;
                          $1->parametertypelist=s->parametertypelist;
                          $1->variablenamelist=s->variablenamelist;
                         //assembly
                          $1->assnamelist=s->assnamelist;

                         // $$->variabletype=$1->variabletype;

                           /*for(int i=0;i<$1->parametertypelist.size();i++)
                    {
                     filelog<<"in arguument_list factor  "<<$1->parametertypelist[i]<<" "<<$1->variablenamelist[i]<<"\n\n";
                    } */ 
                      /* if($1->variabletype=="VOID")
                       {  
                fileerror<<"Error at line "<<linecount<<" : variable type of function : "<<$1->getname()<<" is void\n\n";
                     semerror++;
                            }*/


                       
                         if($1->parameterno!=$3->parameterno)
                          {
                          //filelog<<"parameterno "<<$1->parameterno<<" "<<$3->parameterno<<"\n\n";
               fileerror<<"Error at line "<<linecount<<" : parameter number  in function call of : "<<$1->getname()<<" do not match\n\n";
                           semerror++;
                           f=0;}
                          else {
                           for(int i=0;i<$1->parametertypelist.size();i++)
                            {
                          // cout<<"in factor id  "<<$1->parametertypelist[i]<<" "<<$1->variablenamelist[i]<<"\n\n";
                           if($1->parametertypelist[i]!=$3->parametertypelist[i])
                              {
                 fileerror<<"Error at line "<<linecount<<" : parameter type in function call of : "<<$1->getname()<<" do not match\n\n";
                              semerror++;
                             f=0;}
                             } 
                           }
                       }
                     if(f==1)
                    {
                    $$->variabletype=$1->variabletype;
                    
                  
                   //}

                    //assembly
                   /*for(int i=0;i<$1->assnamelist.size();i++)
                    {
                     filelog<<"assnames func id in argument "<<$1->assnamelist[i]<<"\n";
                    }*/
                     for(int i=0;i<$3->assnamelist.size();i++)
                    {
                     filelog<<"assnames func id in argument "<<$1->assnamelist[i]<<"\n";
                     filelog<<"assnames func id in argument "<<$3->assnamelist[i]<<"\n";
                      $$->code+="\tmov ax,"+$3->assnamelist[i]+"\n";
                     $$->code+="\tmov "+$1->assnamelist[i]+",ax\n";
                    
                    }

                    }
                   //$$->code=$3->code;
                 

                   //$$->code="\tmov ax,"+$3->assname+"\n";
                   //$$->code="\tmov "+$1->assname+",ax\n";

                  $$->code+="\tcall "+$1->getname()+"\n";
                  $$->assname="bp";
                  filelog<<$$->code<<"\n";
                
                    
                  
             } 
	| ID LPAREN RPAREN 
            {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: ID LPAREN  RPAREN \n\n";
                   filelog<<$1->line<<" "<<$2->line<<"  "<<$3->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line;
                  
                      symbol *s;

                      s=st->lookupscope($1->getname());
                      int f=1;

                      if(s==NULL)
                      {  
                         
                         filelog<<"does not exist in current scope table\n\n";
                         fileerror<<"Error at line "<<linecount<<" : does not exist this function : "<<$1->getname()<<"\n\n";
                          semerror++; f=0;
                      }
                      else if(s->idtype!="FUNCTION")
                    { 
                         fileerror<<"Error at line "<<linecount<<" : this function : "<<$1->getname()<<" is not declared \n\n";
                         semerror++;
                         f=0;
                     }

                       
                      else{
                        //  filelog<<"function "<<s->getname()<<" "<<s->variabletype<<" "<<s->idtype<<"\n\n";
                          $1->variabletype=s->variabletype;
                          $1->idtype=s->idtype;
                          $1->parameterno=s->parameterno;

                           if($1->parameterno!=0)
                        {
                         fileerror<<"Error at line "<<linecount<<" : this function : "<<$1->getname()<<" have parameters \n\n";
                          semerror++;
                          f=0;
                        }
                          
                         // $$->variabletype=$1->variabletype;

                         

                      
                       
                        
                       }
                     if(f==1)
                    {
                    $$->variabletype=$1->variabletype;
                    }
                    //assembly
                  $$->code+="\tcall "+$1->getname()+"\n";
                    $$->assname="bp";
                  filelog<<$$->code<<"\n";
                    
                  
             } 
         
          |LPAREN expression RPAREN
          {      $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: LPAREN expression RPAREN\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                    $$->line=$1->line+$2->line+$3->line;
                    $$->variabletype=$2->variabletype;
                      //assembly
                       $$->assname=$2->assname;
                       $$->code=$2->code;
                    
                   
           } 
	| CONST_INT 
             {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: CONST_INT \n\n";
                  $$=$1;
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  
                  $$->assname=$1->getname();
                  
                  $$->variabletype="INT";
             } 
	| CONST_FLOAT
            {       $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : factor: CONST_FLOAT \n\n";
                   $$=$1;
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                   $$->assname=$1->getname();
                   
                   $$->variabletype="FLOAT";
                   
                 } 
	| variable INCOP 
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: variable INCOP  \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$1->variabletype;
                
                  //assembly
                  $$->assname=$1->assname;
                  
                  
              
               
                  $$->code += "\tmov ax , " + $$->assname+ "\n";
		  $$->code += "\tadd ax , 1\n";
		  $$->code += "\tmov " + $$->assname + " , ax\n";
                  filelog<<$$->code<<"\n";
                 
             } 
	| variable DECOP
          {       $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : variable DECOP\n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$1->variabletype;

                 //assembly
                  $$->assname=$1->assname;
               
                  $$->code += "\tmov ax , " + $$->assname+ "\n";
		  $$->code += "\tsub ax , 1\n";
		  $$->code += "\tmov " + $$->assname + " , ax\n";
                  filelog<<$$->code<<"\n";
          } 
	;
	
argument_list : arguments
                   { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : argument_list : arguments\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                  $$->parameterno=paramnumber;
                
                   //filelog<<"param in argument "<<$$->parameterno<<"\n\n";
                  /* for(int i=0;i<$$->parametertypelist.size();i++)
                    {
                     filelog<<"in arguument_list  "<<$$->parametertypelist[i]<<" "<<$$->variablenamelist[i]<<"\n\n";
                    } */
                    //assembly
                   $$->code=$1->code;
              
                   filelog<<$$->code<<"\n";
			  
		 }	  ;
	
arguments : arguments COMMA logic_expression
                { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : arguments : arguments COMMA logic_expression\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                   $$->parametertypelist=$1->parametertypelist;  
		   $$->variablenamelist=$1->variablenamelist; 
                   $$->assnamelist=$1->assnamelist; 

                   $$->parametertypelist.push_back($3->variabletype);
                   $$->variablenamelist.push_back($3->getname());
                     $$->assnamelist.push_back($3->assname);
                   paramnumber++;
                    //assembly
                   $$->code=$1->code;
                   //$$->code+="\tmov ax, "+$3->assname+"\n"+"\tpush ax\n";
                   filelog<<$$->code<<"\n";


                 } 
	      | logic_expression
               {  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : arguments : logic_expression\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                  paramnumber=1;
                  
                  $$->parametertypelist.push_back($1->variabletype);
                  $$->variablenamelist.push_back($1->getname());
                   $$->assnamelist.push_back($1->assname);
                  

                   //assembly
                   //$$->code="\tmov ax, "+$1->assname+"\n"+"\tpush ax\n";
                    filelog<<$$->code<<"\n";
                    
                  
                } 
	      ;

%%
int main(int argc, char *argv[]){

	if(argc!=2){
		cout <<"Please provide input file name and try again" << endl ;
		return 0;
	}

	FILE *in=fopen(argv[1],"r");
	if(in==NULL){
		cout << "Cannot open specified file" << endl ;
		return 0;
	}

	yyin = in ;
	
	yyparse() ;
        st->printcurrent(filelog);
	
	filelog << "Total lines: " << linecount-1 << endl <<endl;
        fileerror << "Total lines: " << linecount-1 << endl <<endl;
        fileerror<< "Total errors: " <<  semerror << endl <<endl;
	
	
	filelog.close() ;
	fileerror.close() ;
	fclose(in) ;

}
