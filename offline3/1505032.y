%{

#include<bits/stdc++.h>
#include<vector>

#include "1505032_symboltable.h"

using namespace std;



string type_var;
int yyparse(void);
int yylex(void);
extern int linecount;
extern FILE *yyin;
int flag = 0 ;
symboltable *st=new symboltable(7);
symbol *check = new symbol();
int paramnumber;
int semerror=0;
string returntype="";


ofstream filelog("1505032_log.txt") ; 
ofstream fileerror("1505032_error.txt");

void yyerror(char *s)
{
	
cout << "ERROR OCCURED" << endl ;
fileerror<<"Error at line : "<<linecount<<"error occured\n\n";
semerror++;
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
	}
	;

program : program unit 
           {
            $$ = new symbol() ;
            filelog<<"Line :"<<linecount<<" : program : program unit\n\n";
            filelog<<$1->line<<" "<<$2->line<<"\n\n";
            $$->line=$1->line+$2->line;}
	| unit
            {
            filelog<<"Line :"<<linecount<<" : program : unit\n\n";
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
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
              }
                        
     | func_definition{
            $$ = new symbol() ; 
            filelog<<"Line :"<<linecount<<" : unit : func_definition\n\n";
            filelog<<$1->line<<"\n\n";
            $$->line=$1->line;
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
                    // filelog<<"checkkkk "<<check->parameterno<<"\n\n";
                     
                       
                        symbol *searchpoint;
               
                        searchpoint=st->lookupscope($2->getname());
                       

                    
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
                       {  
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

		   } compound_statement
                  {$$ = new symbol() ;
                 filelog<<"Line :"<<linecount<<" : func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";  
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$7->line;
                        
                     
                   }
		| type_specifier ID LPAREN RPAREN {

                 returntype=$1->variabletype;// filelog<<"return type in def "<<returntype<<"\n\n";
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
                      $$->parameterno=paramnumber;}
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
                          }
                       
                       }
                      }
                    

                      } statements{st->printcurrent(filelog);} RCURL{st->exitscope(filelog);}
 
                    { $$ = new symbol() ;
                     filelog<<"Line :"<<linecount<<" : compound_statement : LCURL statements RCURL\n\n";
                     filelog<<$1->line<<" "<<$3->line<<" "<<$5->line<<"\n\n";
                      $$->line=$1->line+$3->line+$5->line;
                  
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
                           $$=s;
                             }
                    }


                  
                 }
                  
 		  | ID LTHIRD CONST_INT RTHIRD
                     {
                    $$ = new symbol() ;
                    filelog<<"Line :"<<linecount<<" : declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                    $$->line=$1->line+$2->line+$3->line+$4->line;
                  
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
                           s->line=$1->line;
                           $$=s;
                             }
                    }


                    }
 		  ;
 		  
statements : statement
               {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statements : statement\n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                }
	   | statements statement
               {
                   $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : statements : statements statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                  
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
                 }
	  | compound_statement
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : compound_statement\n\n";
                  filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                 }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
            {
                   $$ = new symbol() ;
          filelog<<"Line :"<<linecount<<" : statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line+$7->line;}
	  | IF LPAREN expression RPAREN statement  %prec lower
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : IF LPAREN expression RPAREN statement\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                 }
	  | IF LPAREN expression RPAREN statement ELSE statement
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<" "<<$6->line<<" "<<$7->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line+$6->line+$7->line;
                 }
	  | WHILE LPAREN expression RPAREN statement
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : WHILE LPAREN expression RPAREN statement\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<" "<<$5->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line+$5->line;
                   symbol *searchpoint;

                       searchpoint=st->lookupscope($3->getname());

                      if(searchpoint==NULL)
                      {
                        
                         fileerror<<"Error at line "<<linecount<<" :does not exist this ID :"<<$3->getname()<<"\n\n";
                          semerror++;
                         
                      }
                }
          | PRINTLN LPAREN ID RPAREN error
              {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : statement : PRINTLN LPAREN ID RPAREN error\n\n";
                   filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<" "<<$4->line<<"\n\n";
                   $$->line=$1->line+$2->line+$3->line+$4->line;
                      symbol *searchpoint;
                     searchpoint=st->lookupscope($3->getname());

                      if(searchpoint==NULL)
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
            }	 
	 ;
	 
expression : logic_expression
             	 {
                  $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : expression : logic_expression\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;}
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
      
               } 	
	   ;
			
logic_expression : rel_expression 
                   { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : logic_expression : rel_expression \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
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
                  } 	
		 ;
			
rel_expression	: simple_expression 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : simple_expression \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                 // filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                  } 
		| simple_expression RELOP simple_expression
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : simple_expression RELOP simple_expression\n\n";
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
                  } 	
		;
				
simple_expression : term 
                   { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : simple_expression : term \n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
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
                 } 
		  ;
					
term :	unary_expression
            {     $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : term : unary_expression\n\n";
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
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



 
              }
     ;

unary_expression : ADDOP unary_expression 
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : ADDOP unary_expression \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                   $$->line=$1->line+$2->line;
                   $$->variabletype=$2->variabletype;
                  }  
		 | NOT unary_expression 
                  {$$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : NOT unary_expression \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$2->variabletype;
                  } 
		 | factor
                  { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : unary_expression : factor \n\n";
                  filelog<<$1->line<<"\n\n";
                  
                  
                 //filelog<<"function "<<$1->getname()<<" "<<$1->variabletype<<" "<<$1->idtype<<"\n\n"; 
              
                  $$=$1;
                 
                 //filelog<<"function "<<$$->getname()<<" "<<$$->variabletype<<" "<<$$->idtype<<"\n\n"; 
                  } 
		 ;
	
factor	: variable 
            {     $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: variable \n\n";
                 
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
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
                    }

                    
                  
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

                    
                  
             } 
         
          |LPAREN expression RPAREN
          {      $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: LPAREN expression RPAREN\n\n";
                    filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                    $$->line=$1->line+$2->line+$3->line;
                    $$->variabletype=$2->variabletype;
                    
                   
           } 
	| CONST_INT 
             {   $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: CONST_INT \n\n";
                  
                  filelog<<$1->line<<"\n\n";
                  $$->line=$1->line;
                  $$=$1;
                  $$->variabletype="INT";
             } 
	| CONST_FLOAT
            {       $$ = new symbol() ;
                   filelog<<"Line :"<<linecount<<" : factor: CONST_FLOAT \n\n";
                   filelog<<$1->line<<"\n\n";
                   $$->line=$1->line;
                   $$=$1;
                   $$->variabletype="FLOAT";
                   
                 } 
	| variable INCOP 
             {    $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : factor: variable INCOP  \n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$1->variabletype;
                  
             } 
	| variable DECOP
          {       $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : rel_expression : variable DECOP\n\n";
                  filelog<<$1->line<<" "<<$2->line<<"\n\n";
                  $$->line=$1->line+$2->line;
                  $$->variabletype=$1->variabletype;
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
			  
		 }	  ;
	
arguments : arguments COMMA logic_expression
                { $$ = new symbol() ;
                  filelog<<"Line :"<<linecount<<" : arguments : arguments COMMA logic_expression\n\n";
                  filelog<<$1->line<<" "<<$2->line<<" "<<$3->line<<"\n\n";
                  $$->line=$1->line+$2->line+$3->line;
                   $$->parametertypelist=$1->parametertypelist;  
		   $$->variablenamelist=$1->variablenamelist; 
                   $$->parametertypelist.push_back($3->variabletype);
                   $$->variablenamelist.push_back($3->getname());
                   paramnumber++;
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
	
	filelog << "Total lines: " << linecount-1 << endl ;
        fileerror<< "Total errors: " <<  semerror << endl ;
	
	
	filelog.close() ;
	fileerror.close() ;
	fclose(in) ;

}
