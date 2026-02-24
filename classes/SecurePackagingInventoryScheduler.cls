global class SecurePackagingInventoryScheduler implements schedulable{

    global void execute(SchedulableContext sc){
        
       Integer securePackagingDSCount = [select count() from Secure_packaging__c where name like 'DS%' AND status__c = 'Available' AND RecordTypeID='0125g0000003dGBAAY' ];
        system.debug('securePackagingCount@@@'+securePackagingDSCount);
 
       
        if(securePackagingDSCount <= 10000){
            SecurePackagingInventoryBatch bc = new SecurePackagingInventoryBatch();
             id jobId =database.executebatch(bc,2000);
             system.debug(jobId);
              
        }
        
         Integer securePackagingESCount = [select count() from Secure_packaging__c where name like 'ES%' AND status__c = 'Available' AND RecordTypeID='0125g0000003dGBAAY' ];
        if(securePackagingESCount <= 10000){
            SecurePackagingESInventoryBatch  ES = new SecurePackagingESInventoryBatch();
            id jobUVId =database.executebatch(ES,2000);
             system.debug(jobUVId);
        }   
    }
}