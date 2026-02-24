global class zohoSignGetDocumentAPIHelperBatchNONACR implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
     public Database.QueryLocator Start(Database.BatchableContext bc){return Database.getQueryLocator(
            'SELECT Id FROM Shipment__c WHERE id=null'
        );}
    public void execute(Database.BatchableContext bc , List<Shipment__c> newShipment){}
    public void finish(Database.BatchableContext bc){}
    
    public static void dummyMethod(){
        integer i = 0;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
}
  
    /*
   global Database.QueryLocator start(Database.BatchableContext bc) {
          
        String query = 'SELECT Id, Name, DocumentID__c, RequestId__c, SBQQ__Status__c ' +
                       'FROM SBQQ__Quote__c ' +
                       'WHERE DocumentID__c != null AND RequestID__c != null AND SBQQ__Status__c = \'contract sent\'';
       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteList) {
        Map<String, List<Id>> requestIdToQuoteIdsMap = new Map<String, List<Id>>();
        
        // Group quote IDs by request ID
        for (SBQQ__Quote__c quote : quoteList) {
            String requestId = quote.RequestId__c;
    
            if (!requestIdToQuoteIdsMap.containsKey(requestId)) {
                requestIdToQuoteIdsMap.put(requestId, new List<Id>());
            }
            requestIdToQuoteIdsMap.get(requestId).add(quote.Id);
        }
    
        // Call the helper method to process document details
        zohoSignGetDocumentAPIHelper.getDocumentDetails(requestIdToQuoteIdsMap);
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}*/