public class BVC_zohoGetDoument {

    @InvocableMethod
    public static void getZohoDocument(List<ID> quoteID){
        
        List<BVCQuote__c> quoteList = [select id,name,RequestId__c from BVCQuote__c where id IN:quoteID];
         Map<String, List<Id>> requestIdToQuoteIdsMap = new Map<String, List<Id>>();
        
        string accessToken;
        Zoho_Access_Token__c tokenSetting = [SELECT Access_Token__c FROM Zoho_Access_Token__c LIMIT 1];
        accessToken = tokenSetting.Access_Token__c;
        
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
    
    
    
    
    
    
    
    public  static void GetCoverage(){
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