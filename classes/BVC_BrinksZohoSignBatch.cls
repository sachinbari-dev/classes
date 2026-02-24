global class BVC_BrinksZohoSignBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

     global Database.QueryLocator start(Database.BatchableContext bc) {
         
         String query = 'SELECT Name, Id, BVC_Brink_s_Office_Address__c, Customer_Address__c, Customer_GST_No__c, Status__c, Customer_IEC_No__c, Customer_Name__c, Customer_Name__r.Name, You_are__c, Customer_Email__c, Document_Type__c FROM BVC_bulk_Agreement_signing__c WHERE Status__c = \'draft\'';
         system.debug('query@@@'+ query);
          return Database.getQueryLocator(query);
     }
     global void execute(Database.BatchableContext bc, List<BVC_bulk_Agreement_signing__c> bulkList) {
         List<BVC_bulk_Agreement_signing__c>  brinksId = new List<BVC_bulk_Agreement_signing__c>();
         for(BVC_bulk_Agreement_signing__c  bl : bulkList){
             bl.APICalled__c = true;
             brinksId.add(bl);
         }
         
         update brinksId;
     }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}