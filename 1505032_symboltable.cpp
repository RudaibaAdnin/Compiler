#include<bits/stdc++.h>
using namespace std;


class symbol
{

    string name;
    string type;
public:
    symbol *next;
    symbol()
    {
        next = NULL;
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
    bool Insert(string Name, string Type)
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
        return true;

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

    }
    void print()
    {

        cout<<"\nScope table "<<id<<"\n";
        for (int i=0; i<TABLE_SIZE; i++)
        {
            symbol* entry = htable[i];

            cout<< i << "--->    ";
            while (entry != NULL)
            {



                cout<<"<" << entry->getname()<<" : ";

                cout<<entry->gettype()<<">" <<" ";

                entry = entry->next;
            }
            cout<<"\n";
        }
    }
};



class symboltable
{
public:
    int m=0;
    scope *head;
    int table_size;
    symboltable(int table_size)
    {
        //head= new scope(table_size);
        this->table_size=table_size;
        //cout<<"table size is==> "<<table_size<<"\n";
        head=NULL;
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
    void enterscope()
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
        }


    }
    void exitscope()
    {
        scope *exithead;

        exithead=head;
        head=exithead->next;
        cout<<"\nscope with id "<<m<< " removed\n";
        m--;

        //
        delete exithead;

    }
    bool insertscope(string Name,string Type)
    {

        bool del;
        symbol *searchpoint;

        searchpoint=head->Search(Name);

        if(searchpoint!=NULL)
        {
            cout<<"\nAlready exist in current scope table\n";
            return false;
        }
        else
        {
            //cout<<"\nInserted in Scope Table==> " << m << " ";
            del=head->Insert(Name,Type);
            // head->print();
            // cout<<"\n";
            // cout<<"\n";
            return true;

        }

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
    void printcurrent()
    {
        cout<<"\ncurrent scope table==> "<<"\n";
        head->print();
    }
    void printall()
    {
        scope *temp;
        temp=new scope(table_size);
        temp=head;

        //cout<<"\n all scope table==> "<<"\n";
        while(temp!=NULL)
        {
            //printf("%d->\n\n\n", temp->val);
            temp->print();
            temp = temp->next;
        }
        printf("\n");

    }


};

int main()
{



    /*  char ch;
      //string Name;
      //string Type;
      int length;

      cin>>length;
      symboltable st(length);
      st.enterscope();
      while(1)
      {
          cout<<"1. press I for insert...2. L for look up 3. D for delete...\n";
          cout<<"4.P for print .. 5. S for new scope... 6. E for exit scope..";
          cout<<"7.F for exit\n\n";
          cin>>ch;
          if(ch=='I')
          {
              string Name;
              string Type;
              cin>>Name;
              cin>>Type;
              st.insertscope(Name,Type);
          }
          if(ch=='L')
          {
              string Name;
              //string Type;
              cin>>Name;
              //cin>>Type;
              st.lookupscope(Name);
          }
          if(ch=='D')
          {
              string Name;
              //string Type;
              cin>>Name;
              //cin>>Type;
              st.removescope(Name);
          }
          if(ch=='P')
          {

              char ch1;
              cin>>ch1;
              if(ch1=='A')
              {

                  st.printall();
              }
              else
              {

                  st.printcurrent();
              }
          }
          if(ch=='F')
          {
              exit(1);
          }
          if(ch=='S')
          {

              st.enterscope();
          }
          if(ch=='E')
          {

              st.exitscope();
          }
      }*/

    int length;
    char ch, ch1;
    //string name, type;


    std::ifstream in("input.txt");

    in >> length;

    symboltable st(length);
    st.enterscope();

    while(!in.eof())
    {
        //in >> ch;
        in>>ch;
        if(ch=='I')
        {
            string Name;
            string Type;
            in>>Name;
            in>>Type;
            st.insertscope(Name,Type);
        }
        if(ch=='L')
        {
            string Name;
            //string Type;
            in>>Name;
            //cin>>Type;
            st.lookupscope(Name);
        }
        if(ch=='D')
        {
            string Name;
            //string Type;
            in>>Name;
            //cin>>Type;
            st.removescope(Name);
        }
        if(ch=='P')
        {

            char ch1;
            in>>ch1;
            if(ch1=='A')
            {

                st.printall();
            }
            if(ch1=='C')
            {

                st.printcurrent();
            }
        }
        if(ch=='F')
        {
            exit(1);
        }
        if(ch=='S')
        {

            st.enterscope();
        }
        if(ch=='E')
        {

            st.exitscope();
        }
    }
    return 0;


}
