@RestResource(urlMapping='/ContentRecordAPI/*')
global class getContentVersionRecordById {

     @HttpPost 
    global static void getInvoiceData() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        
       List<Object> linkedEntityIdsRaw  = (List<Object>) payload.get('linkedEntityIds');

       List<String> linkedEntityIds = new List<String>();
        if (linkedEntityIdsRaw != null) {
            for (Object id : linkedEntityIdsRaw) {
                linkedEntityIds.add(String.valueOf(id));
            }
        }
        
      
        if (linkedEntityIds == null || linkedEntityIds.isEmpty()) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"No linked entity IDs provided"}');
            return;
        }
 
          
            List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId 
                                                              FROM ContentDocumentLink 
                                                              WHERE LinkedEntityId IN :linkedEntityIds];
    
           
            List<Map<String, Object>> responseList = new List<Map<String, Object>>();
            
          
            Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink cdl : contentDocumentLinks) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
    
          
                List<ContentVersion> contentVersions = [SELECT Id,Title, ContentDocumentId, VersionData 
                                                        FROM ContentVersion 
                                                        WHERE ContentDocumentId IN :contentDocumentIds];
        
                
                Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
                for (ContentVersion cv : contentVersions) {
                    contentVersionMap.put(cv.ContentDocumentId, cv);
                }
    
            
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                ContentVersion cv = contentVersionMap.get(cdl.ContentDocumentId);
                if (cv != null) {
                    Map<String, Object> contentMap = new Map<String, Object>();
                    contentMap.put('ContentDocumentLinkId', cdl.Id);
                    contentMap.put('LinkedEntityId', cdl.LinkedEntityId);
                    contentMap.put('ContentVersionId', cv.Id);
                     contentMap.put('FileName', cv.Title);
                    contentMap.put('ContentDocumentId', cv.ContentDocumentId);
                    contentMap.put('VersionData', cv.VersionData != null ? EncodingUtil.base64Encode(cv.VersionData) : null);
                    
                    responseList.add(contentMap);
                }
            }
    
       
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serializePretty(responseList));
    }
}