public class OrgRelationships {

    public OrgRelationships()
    {
    }
       
    public OrgRelationships( Organization_Relationship__c[] Relationships,  Organization_Relationship__c[] oldRelationships, Integer ta)
    {
    
        List< Organization_Relationship__c> origrelationships = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToDelete = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> reciprocalsToUpdate = new List< Organization_Relationship__c>();
        
        Integer i = 0; // processing counter
        
        for( Organization_Relationship__c r : Relationships)
        {
            // AFTER INSERT
            if (ta==3)
            {
                if (r.Reciprocal_Organization_Relationship__c == null)
                {
                    relationshipsToCreate.add(r);
                }
                if (r.Reciprocal_Organization_Relationship__c != null)
                {
                    reciprocalsToUpdate.add(r);
                }
            }
            
            // AFTER UPDATE
            if (ta==4)
            {
                if (r.Reciprocal_Organization_Relationship__c == oldRelationships[i].Reciprocal_Organization_Relationship__c && r.Related_Account__c != null)
                {
                    relationshipsToUpdate.add(r);
                    origRelationships.add(oldRelationships[i]);
                }
                if (r.Related_Account__c == null)
                {
                    relationshipsToDelete.add(r);
                }
            }
            
            // AFTER DELETE
            if (ta==5)
            {
                if (r.Reciprocal_Organization_Relationship__c != null)
                {
                    relationshipsToDelete.add(r);
                }
            }
            
            i += 1;
        }
        
        if (relationshipsToCreate.size() > 0 ) 
        {
            createRelationship(relationshipsToCreate);
        }
        if (relationshipsToUpdate.size() > 0 ) 
        {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }
        if (reciprocalsToUpdate.size() > 0 ) 
        {
            reciprocate(reciprocalsToUpdate);
        }
        if (relationshipsToUpdate.size() > 0 ) 
        {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }
        if (relationshipsToDelete.size() > 0 ) 
        {
            deleteRelationship(relationshipsToDelete);
        }
    }
    
    public static void deleteRelationship( Organization_Relationship__c[] relationships)
    {
        List<Id> relationshipsToDelete = new List<Id>();
        for( Organization_Relationship__c r : Relationships)
        {
            if (r.Reciprocal_Organization_Relationship__c != null)
            {
                relationshipsToDelete.add(r.Reciprocal_Organization_Relationship__c);
            } 
            else if (r.Related_Account__c == null)
            {
                relationshipsToDelete.add(r.Id);
            }
        }
        if ( relationshipsToDelete.size() > 0 )
        {
            Database.DeleteResult[] lsr = Database.delete(relationshipsToDelete, false);
        }    
    }

    public static void deleteEmptyRelationships()
    {
        system.debug('<==Inside deleteEmptyRelationships==>');
        List< Organization_Relationship__c> relationshipsToDelete = new List< Organization_Relationship__c>();
        for ( Organization_Relationship__c r : [Select Id from  Organization_Relationship__c where Related_Account__c = null])
        {
            relationshipsToDelete.add(r);
        }
        if ( relationshipsToDelete.size() > 0 )
        {
            Database.DeleteResult[] lsr = Database.delete(relationshipsToDelete, false);
        }
    }

    public static void reciprocate( Organization_Relationship__c[] Relationships)
    {
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        for( Organization_Relationship__c r : Relationships)
        {
             Organization_Relationship__c copy = new  Organization_Relationship__c(Id=r.Reciprocal_Organization_Relationship__c, Reciprocal_Organization_Relationship__c=r.Id);
            relationshipsToUpdate.add(copy);
        }
        update relationshipsToUpdate;
    }

    public static void createRelationship( Organization_Relationship__c[] Relationships)
    {
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        for( Organization_Relationship__c r : Relationships)
        {
             Organization_Relationship__c copy = new  Organization_Relationship__c();
            copy.Account__c = r.Related_Account__c;
            copy.Related_Account__c = r.Account__c;
            copy.Status__c = r.Status__c;
            copy.Type__c = r.Type__c;
            copy.Reciprocal_Organization_Relationship__c = r.Id;
            copy.Description__c = r.Description__c;
            relationshipsToCreate.add(copy);
        }
        
        insert relationshipsToCreate;
        
    }

    public static void updateRelationship( Organization_Relationship__c[] Relationships,  Organization_Relationship__c[] oldRelationships)
    {
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        Integer counter = 0; // processing counter
        
        for( Organization_Relationship__c r : Relationships)
        {
            if ((r.Status__c != oldRelationships[counter].Status__c || r.Type__c != oldRelationships[counter].Type__c || r.Description__c != oldRelationships[counter].Description__c)&& r.Reciprocal_Organization_Relationship__c != null)
            {
                 Organization_Relationship__c copy = new  Organization_Relationship__c(Id=r.Reciprocal_Organization_Relationship__c);
                
                if(oldRelationships[counter].Related_Account__c!=r.Related_Account__c)
                {
                    copy.Account__c = r.Related_Account__c;
                }
                copy.Status__c = r.Status__c;
                copy.Type__c = r.Type__c;
                copy.Description__c = r.Description__c;
                relationshipsToUpdate.add(copy);
            }
        counter += 1;
        }
        update relationshipsToUpdate;
    }

    static testMethod void Relationships_Test() 
    {
        OrgRelationships testRelationships = new OrgRelationships();
    }

    static testMethod void createRelationship_Test() 
    {
        Account con = new Account(Name='test');
        insert con;
        
        Account con2 = new Account(Name='Contact2');
        insert con2;
        
         Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        insert r;        
        
         Organization_Relationship__c[] rList = [select Id,Account__c from  Organization_Relationship__c where Id = :r.Id];
        System.assert(rList.size()>0);
         Organization_Relationship__c r2 = rList[0];
        r2.Status__c='Test2';
        
        update r2;
    }

    static testMethod void deleteRelationship_Test() 
    {
        Account con = new Account(Name='contact');
        insert con;
        
        Account con2 = new Account(Name='Contact2');
        insert con2;
        
         Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        insert r;
        
        delete r;
    }

    static testMethod void deleteEmptyRelationships_Test() 
    {
        Account con = new Account(Name='contact');
        insert con;
        
        Account con2 = new Account(Name='Contact2');
        insert con2;
        
         Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        insert r;
        
        delete con2;
    }

}