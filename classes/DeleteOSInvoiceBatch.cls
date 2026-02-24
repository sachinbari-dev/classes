global class DeleteOSInvoiceBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id From BVC_CB_OS_Invoice__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BVC_CB_OS_Invoice__c> osInvoiceList) {
        if(osInvoiceList.size()>0){
           delete osInvoiceList; 
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
}