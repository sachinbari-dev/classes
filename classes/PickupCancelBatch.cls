public class PickupCancelBatch implements Database.Batchable<sObject> 
{   
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
         System.debug('Batch Class Started');
        String Status ='Created'; 
        // SELECT id, Name, Pickup_Status__c, Pickup_Date__c, Created_Date__c, (select Id from Shipments__r) FROM Pickup__c WHERE CreatedDate = LAST_N_DAYS:30 and Pickup_Status__c='Created' and Id not In (SELECT Pickup__c FROM Shipment__c)
        // String query='SELECT id, Name, Pickup_Status__c, Pickup_Date__c, Created_Date__c, (select Id from Shipments__r) FROM Pickup__c WHERE CreatedDate <= YESTERDAY and Pickup_Status__c=\'Created\'';
        String query='SELECT id, Name, Pickup_Status__c, Pickup_Date__c, Created_Date__c, (select Id from Shipments__r) FROM Pickup__c WHERE CreatedDate = LAST_N_DAYS:30 and Pickup_Status__c=\'Created\'';
        query= query+' and Id not In (SELECT Pickup__c FROM Shipment__c) and Customer__c!=null and Shipper_Name__c!=null and Shipper_Address__c!=null';
        System.debug('QUERY :'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Pickup__c> scope)
    {
        System.debug('Inside Execute');
        List<Pickup__c> upList = new List<Pickup__c>();        
        for (Pickup__c pk : scope) 
        {
            if(pk.Shipments__r.size()==0)	// checking for id the Pickup Shipments size = 0
            { 
                System.debug('pk :'+pk.Name);
                System.debug('Ship Size :'+pk.Shipments__r.size());            
                pk.Pickup_Status__c='Cancelled';
                // pk.Pickup_Date__c= System.today();
                pk.Pickup_Date__c= pk.Created_Date__c;
                upList.add(pk);						// collecting the Pickups            
            }
        }
        for (Pickup__c pk : upList) 
        {
            System.debug('pk Name:'+pk.Name);
            System.debug('pk Pickup_Status__c :'+pk.Pickup_Status__c);
        }
        System.debug('Found without Ships :'+upList.size());
        if(upList.size()>0)
        {
            System.debug('Before Update');
            //update upList;
            Database.update(upList, false);
            System.debug('After Update');
            // Database.update(upList, false);
        }        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
}