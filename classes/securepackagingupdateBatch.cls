global class securepackagingupdateBatch implements Database.Batchable<sObject>,Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Name,digital__c,Shipment__c, Status__c,Consumed_in_Universe__c FROM Secure_Packaging__c WHERE Name LIKE \'UV%\' AND status__c =\'consumed\' AND shipment__c != Null AND Consumed_in_Universe__c = false  AND RecordTypeID=\'0125g0000003dGBAAY\' ';
       
        system.debug('query@@@'+ query);
      
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext bc, List<Secure_Packaging__c> scope){

        List<secure_packaging__c> spList = new List<secure_packaging__c>();
        for(secure_packaging__c sp:scope){
            if(sp.Consumed_in_Universe__c == false){
                 sp.Consumed_in_Universe__c = true;
                 spList.add(sp);
            }
            
        }
        update spList;
        system.debug('spList@@@@'+spList);
          
    }
     global void finish(Database.BatchableContext bc){
            
    }

}