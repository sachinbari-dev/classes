global class SendACRReportBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query the records you want to process
        String query = 'Select id from account where Customer_Category_Static__c = \'ACR\' AND Id =\'0015g00000vGbgtAAC\' AND Active_Contract__c != null AND Active_Contract__r.Latest_Contract__c = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Instantiate and call the main logic from the existing class for each batch
        SendACRReport.getAccountAndItsShipments((List<Account>)scope);
    }

    global void finish(Database.BatchableContext BC) {
        // Any post-processing logic if needed
    }
}