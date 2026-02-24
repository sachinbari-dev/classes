global class DeleteDigitalShippingLabelBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From Digital_Shipping_Label__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Digital_Shipping_Label__c> dslList) {
        if(dslList.size()>0){
           delete dslList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}