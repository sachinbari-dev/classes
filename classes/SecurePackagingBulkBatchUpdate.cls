global class SecurePackagingBulkBatchUpdate implements Database.Batchable<SObject>, Database.Stateful{
  
    global List<Id> recordIds;

    global SecurePackagingBulkBatchUpdate(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Consumed_In_Universe__c  FROM Secure_Packaging__c  WHERE Id IN :recordIds ]);
    }

    global void execute(Database.BatchableContext BC, List<Secure_Packaging__c> scope) {
        
        List<Secure_Packaging__c> spList =  new List<Secure_Packaging__c>();
        
        for (Secure_Packaging__c record : scope) {
            
            if(record.Consumed_in_Universe__c == False){
                 record.Consumed_In_Universe__c = true;
                 spList.add(record);
            }
           
        }
        
        update spList;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}