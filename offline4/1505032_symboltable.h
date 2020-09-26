
#include<bits/stdc++.h>
#include<vector>
using namespace std;


class symbol
{
    string name;
    string type;
   
public:
    
    string line;
    string variabletype;
    string returntype;
    string idtype;
    int parameterno ; 
    int arraysize;
    
    string assname;//assembly name
    string code; // assembly code

    vector<string> parametertypelist ; 

    vector<string> variablenamelist ;

    vector<string> assnamelist ;  

    symbol *next;
    symbol()
    {
        next = NULL;
	parameterno = -1;
    }

     void settext(string line)
    {
        this->line=line;
    }
    string gettext()
    {
        return line;
    }
    void setname(string name)
    {
        this->name=name;
    }
    void settype(string type)
    {
        this->type=type;
    }
    string getname()
    {
        return name;
    }
    string gettype()
    {
        return type;
    }
};


class scope
{
private:

    symbol** htable;
public:

    int id;
    scope *next;//parentscope
    int TABLE_SIZE;
    scope(int TABLE_SIZE)
    {
        this->TABLE_SIZE=TABLE_SIZE;
        htable = new symbol*[TABLE_SIZE];
        for (int i = 0; i < TABLE_SIZE; i++)
        {

            htable[i] = NULL;
        }
    }
    ~scope()
    {
        for (int i = 0; i<TABLE_SIZE; ++i)
        {
            symbol *entry = htable[i];
            while (entry != NULL)
            {
                symbol* prev = entry;
                entry = entry->next;
                delete prev;
            }
        }
        delete[] htable;
    }

    int HashFunc( string keyname )
    {
        int hashval = 0 ;
        int constant =61;
        // int length=7;
        for( int i=0; i<keyname.length(); i++ )
        {
            hashval=(constant*hashval)+(int)keyname[i] ;
        }

        return abs(hashval)%TABLE_SIZE ;

    }
    symbol* Insert(string Name, string Type)
    {
        int hash_val = HashFunc(Name);
        symbol* prev = NULL;
        symbol* entry = htable[hash_val];
        int p=0;
        while (entry != NULL)
        {
            prev = entry;
            entry = entry->next;
            p++;
        }
        if (entry == NULL)
        {
            entry = new symbol();
            entry->setname(Name);
            entry->settype(Type);
            if (prev == NULL)
            {
                htable[hash_val] = entry;
                entry->next=NULL;
            }
            else
            {
                prev->next = entry;

                entry->next=NULL;
            }
        }
        cout<<"\nInserted in Scope Table==> " << id << " ";
        cout<<"at position "<< hash_val<< "," <<p<<"\n";
        return entry;

    }

    bool Remove(string Name)
    {
        int hash_val = HashFunc(Name);
        //cout<<"index is==> "<< hash_val<<"\n";
        symbol *entry = htable[hash_val];
        symbol *prev = NULL;
        int p=0;
        if (entry == NULL)
        {
            cout<<"NOT found\n";

            return false;
        }
        //do
        if(prev==NULL&&entry->next==NULL&&entry->getname()==Name)
        {
            cout<< "\nFound in ScopeTable "<< id<< "  at position  " << hash_val<<","<<p<<"\n";

            cout<<" Deleted entry at "<<hash_val<<","<<p<< "   from current ScopeTable\n";

            htable[hash_val]=NULL;
            entry=NULL;

            return true;

        }

        if(prev==NULL&&entry->next!=NULL&&entry->getname()==Name)
        {
            cout<< "\nFound in ScopeTable "<< id<< "  at position  " << hash_val<<","<<p<<"\n";
            cout<<" Deleted entry at "<<hash_val<<","<<p<< "   from current ScopeTable\n";

            htable[hash_val]=entry->next;

            return true;



        }
        while(entry->next!=NULL)
        {
            if(entry->getname()==Name)
            {

                cout<< "\nFound in ScopeTable "<< id<< "  at position  " << hash_val<<","<<p<<"\n";
                cout<<"Deleted entry at "<<hash_val<<","<<p<< "   from current ScopeTable\n";
                prev->next=entry->next;
                cout<<"done"<<"\n";

                return true;
            }

            p++;
            prev=entry;

            entry=entry->next;
        }
        if(prev!=NULL&&entry->next==NULL&&entry->getname()==Name)
        {
            cout<< "\nFound in ScopeTable "<< id<< "  at position  " << hash_val<<","<<p<<"\n";

            cout<<"Deleted entry at "<<hash_val<<","<<p<< "   from current ScopeTable\n";
            prev->next=NULL;

            return true;

        }
        if(entry->getname()!=Name)
        {
            cout<<"NOT FOUND\n";

            return false;
        }
         return false;

    }


    symbol * Search(string Name)

    {
        bool flag = false;
        int p=0;
        int hash_val = HashFunc(Name);
        symbol* entry = htable[hash_val];

        while (entry != NULL)
        {
            if (entry->getname()==Name)
            {
                cout<<"\nFound in scope table==> " <<id;
                cout<<"   at position ==>"<<hash_val<<","<<p<<"\n";
                // cout<<entry->getname()<<" ";
                // cout<<entry->gettype()<<" ";
                flag = true;
                return entry;
            }
            entry = entry->next;
            p++;
        }
        if (!flag)
        {
            //cout<<"NOT FOUND\n";
            return NULL;

        }
        return NULL;

    }
    void print()
    {

        cout<<"\nScope table "<<id<<"\n";
         //filelog<<"\nScope table "<<id<<"\n";
        for (int i=0; i<TABLE_SIZE; i++)
        {
            symbol* entry = htable[i];

            cout<< i << "--->    ";
            //filelog<< i << "--->    ";
            while (entry != NULL)
            {



                cout<<"<" << entry->getname()<<" : ";
                //filelog<<"<" << entry->getname()<<" : ";
                

                cout<<entry->gettype()<<">" <<" ";
               // filelog<<entry->gettype()<<">" <<" ";
                entry = entry->next;
            }
            cout<<"\n";
          //filelog<<"\n";
        }
    }
     void printfile(ofstream& tokenlog)
    {

        cout<<"\nScope table "<<id<<"\n";
        tokenlog<<"\nScope table "<<id<<"\n";
        for (int i=0; i<TABLE_SIZE; i++)
        {
            symbol* entry = htable[i];

            cout<< i << "--->    ";
            tokenlog<< i << "--->    ";
            while (entry != NULL)
            {



                cout<<"<" << entry->getname()<<" : ";
                tokenlog<<"<" << entry->getname()<<" : ";
                

                cout<<entry->gettype()<<">" <<" ";
                tokenlog<<entry->gettype()<<">" <<" ";
                entry = entry->next;
            }
            cout<<"\n";
           tokenlog<<"\n";
        }
    }
};



class symboltable
{
public:
    int m;
    scope *head;
    int table_size;
    symboltable(int table_size)
    {   
        m=1;
        head= new scope(table_size);
        head->id=m;
        this->table_size=table_size;
        //cout<<"table size is==> "<<table_size<<"\n";
        //head=NULL;
    }
    ~symboltable()
    {
        scope *d=head;
        while(d!=NULL)
        {
            scope *del=d;
            d=d->next;
            delete d;

        }
    }
    void enterscope(ofstream& f)
    {
        m++;
        scope *newhead;

        newhead=new scope(table_size);

        newhead->id=m;
        newhead->next=head;
        head=newhead;
        if(m>1)
        {
            cout<<"\nNew scope with id "<<m<< " created\n";
            f<<"New scope with id "<<m<< " created\n\n";
        }


    }
    void exitscope(ofstream& f)
    {
        scope *exithead;

        exithead=head;
        head=exithead->next;
        cout<<"\nscope with id "<<m<< " removed\n";
        f<<"scope with id "<<m<< " removed\n\n";
        m--;

        //
        delete exithead;

    }
    symbol* insertscope(string Name,string Type)
    {

        bool del;
        symbol *searchpoint=new symbol();

        searchpoint=head->Search(Name);

        if(searchpoint!=NULL)
        {
            cout<<"\nAlready exist in current scope table\n";
            return NULL; 
        }
        else
        {
            //cout<<"\nInserted in Scope Table==> " << m << " ";
           return head->Insert(Name,Type);
            // head->print();
            // cout<<"\n";
            // cout<<"\n";
            //return true;

        }
        //return false;

    }
    bool removescope(string Name)
    {
        bool del;

        del=head->Remove(Name);
        cout<<"\n";
        cout<<"\n";
        //head->print();

        if(del==true)
        {
            //cout<<"\ntrue\n";
            return true;
        }
        if(del==false)
        {
            //cout<<"\nfalse\n";
            return false;
        }
          return false;

    }
    /* void print()
     {
         scope *temp;
         temp=new scope(table_size,m);
         temp=head;
         while(temp!=NULL)
         {
             printf("%d->", temp->id);
             temp = temp->next;
         }
         printf("\n");

     }*/
    symbol *lookupscope(string Name)
    {
        scope *temp;
        temp=new scope(table_size);
        temp=head;
        symbol *searchpoint=NULL;

        //cout<<"\n found in scope table==> " << m;
        while(temp!=NULL&&searchpoint==NULL)
        {
            // printf("scope value %d->\n\n\n", temp->id);
            searchpoint=temp->Search(Name);
            temp = temp->next;
        }
        if(searchpoint==NULL)
        {
            cout<<"\nNOT FOUND\n";
        }

        return searchpoint;
        // printf("\n");

    }
        symbol *lookupscope1(string Name)
    {
        scope *temp;
        temp=new scope(table_size);
        temp=head;
        symbol *searchpoint=NULL;
       searchpoint=temp->Search(Name);
        if(searchpoint==NULL)
        {
            cout<<"\nNOT FOUND\n";
        }

        return searchpoint;
        // printf("\n");

    }
    void printcurrent(ofstream& f)
    {
        cout<<"\ncurrent scope table==> "<<"\n";
        head->print();
        head->printfile(f);
    }
    void printall()
    {
        scope *temp;
        temp=new scope(table_size);
        temp=head;

        //cout<<"\n all scope table==> "<<"\n";
        while(temp!=NULL)
        {
            
            temp->print();
            temp = temp->next;
        }
        printf("\n");

    }


};


