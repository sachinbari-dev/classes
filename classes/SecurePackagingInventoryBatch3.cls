global class SecurePackagingInventoryBatch3  implements Database.Batchable<sObject>,Database.Stateful{
    private String lastRecordName;   
    
       global Database.QueryLocator start(Database.BatchableContext bc){
        
        // Query the last secure packaging record to get the series name
        
       String query = 'SELECT Name,status__c FROM Secure_Packaging__c WHERE Name LIKE \'DS%\' AND status__c=\'Available\'  AND RecordTypeID=\'0125g0000003dGBAAY\' ORDER BY Name DESC LIMIT 1 ';
     //  string query1 = 'select id,name,status__c from secure_packaging__c where status__c =\'Available\'';
        system.debug('query@@@'+ query);
        Secure_Packaging__c lastRecord = (Secure_Packaging__c)Database.query(query);
        
        if (lastRecord != null) {
            lastRecordName = lastRecord.Name;
        } 
        
        return Database.getQueryLocator(query);
        
     }
        global void execute(Database.BatchableContext bc, List<Secure_Packaging__c> scope){
        
             List<secure_packaging__c> secureLabelList =  new List<secure_packaging__c>();
            Set<String> generatedNames = new Set<String>();            
            
            
               for(integer i = 0 ; i < 10000; i++){
               
               String nextName = SecurePackagingHandler.genNextNameRecord(lastRecordName,i);
               System.debug('Iteration: ' + i + ', Next Name: ' + nextName);
                
                if(!generatedNames.Contains(nextName)){
                    secure_packaging__c spRec= new secure_packaging__c();
                    spRec.Name = nextName;
                    spRec.Status__c = 'Available';
                    spRec.RecordTypeId =  Schema.SObjectType.secure_packaging__c.getRecordTypeInfosByName().get('Shipping Label').getRecordTypeId();
                    spRec.Digital__c = true;
                    spRec.Type_of_Packaging__c = 'Shipping Label';
                    secureLabelList.add(spRec);
                    
                    generatedNames.add(nextName);
                }
                 
            }  
              insert secureLabelList ;
           system.debug('secureLabelList@@@@'+ secureLabelList);
            
     }
    
        global void finish(Database.BatchableContext bc){
            
    }
}