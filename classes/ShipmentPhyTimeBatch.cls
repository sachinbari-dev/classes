public class ShipmentPhyTimeBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Physical_Pickup_Completed_Time1__c,Name,Status__c,Pickup__r.Physical_Pickup_Completed_Time__c ';
        query+='from Shipment__c where Pickup__r.Physical_Pickup_Completed_Time__c !=null ';
        query+='and Pickup__r.Pickup_Status__c =\'Completed\' and CreatedDate >=YESTERDAY and ';
        query+=' Physical_Pickup_Completed_Time1__c=null order by Pickup__r.Physical_Pickup_Completed_Time__c desc limit 1000';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Shipment__c> scope) {
        List<Shipment__c> shipToUpdate = new List<Shipment__c>();
        for (Shipment__c ship : scope) 
        {
           ship.Physical_Pickup_Completed_Time1__c = ship.Pickup__r.Physical_Pickup_Completed_Time__c;
           shipToUpdate.add(ship);
        }
        if(shipToUpdate.size()>0)
        {
            List<Apex_Error_Log__c> errorList = new List<Apex_Error_Log__c>();
            try
            {
                Database.SaveResult[] results = Database.update(shipToUpdate, false);               
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) 
                    {
                        Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'ShipmentPhyTimeBatch - Update',Error__c='Failed record: ' + scope[i].Id +  'Update Error: ' + results[i].getErrors()[0].getMessage());
                        errorList.add(AEL);
                    }
                }                
            } catch(exception e)
            { Apex_Error_Log__c AEL =  new Apex_Error_Log__c(Class_Name__c = 'ShipmentPhyTimeBatch - Update Catch',Error__c=e.getMessage());
               errorList.add(AEL);
            }
            if(errorList.size()>0) { insert errorList; }
        }
    }

    public void finish(Database.BatchableContext bc) {        
    }
}