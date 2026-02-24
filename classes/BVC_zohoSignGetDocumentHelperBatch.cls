global class BVC_zohoSignGetDocumentHelperBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
     private String accessToken;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        Zoho_Access_Token__c tokenSetting = [SELECT Access_Token__c FROM Zoho_Access_Token__c LIMIT 1];
        accessToken = tokenSetting.Access_Token__c;
       
        system.debug('accessToken' + accessToken);
        
     /*   String query = 'SELECT Id, Name, DocumentID__c, RequestId__c, status__c,Document_status__c ' +
                       'FROM BVCQuote__c ' +
                       'WHERE DocumentID__c != null AND RequestID__c != null AND ' +
                       '(status__c = \'Ordered\' OR status__c = \'Contract sent\') AND' +
                       'Document_status__c NOT IN (\'expired\', \'recalled\', \'declined\')';  */
        
        String query = 'SELECT Id, Name, DocumentID__c, RequestId__c, status__c, Document_status__c ' +
               'FROM BVCQuote__c ' +
               'WHERE DocumentID__c != null AND RequestID__c != null AND ' +
               '(status__c = \'Ordered\' OR status__c = \'Contract sent\') AND ' +
               'Document_status__c NOT IN (\'expired\', \'recalled\', \'declined\')';

        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<BVCQuote__c> quoteList) {
        Map<String, List<Id>> requestIdToQuoteIdsMap = new Map<String, List<Id>>();
        
        // Group quote IDs by request ID
        for (BVCQuote__c quote : quoteList) {
            String requestId = quote.RequestId__c;
    
            if (!requestIdToQuoteIdsMap.containsKey(requestId)) {
                requestIdToQuoteIdsMap.put(requestId, new List<Id>());
            }
            requestIdToQuoteIdsMap.get(requestId).add(quote.Id);
        }
    
        // Call the helper method to process document details
        BVC_ZohoSignGetDocumentAPIHelper.getDocumentDetails(requestIdToQuoteIdsMap,accessToken);
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}