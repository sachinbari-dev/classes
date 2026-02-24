@RestResource(urlMapping='/InvoiceDataAPI/*')

global class getContentVersionObjectData {
  @HttpPost 
    global static void getInvoiceData() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

      
        String requestBody = req.requestBody.toString();
        
       
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
      
        String fromCreationDate = (String) payload.get('from');
        String toCreationDate = (String) payload.get('to');

        
        if (fromCreationDate == null || toCreationDate == null || fromCreationDate == '' || toCreationDate == '') {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Invalid date range provided"}');
            return;
        }

       
        Date fromDate;
        Date toDate;
        try {
            fromDate = Date.valueOf(fromCreationDate);
            toDate = Date.valueOf(toCreationDate);
            if (fromDate > toDate) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"From date must be before To date"}');
                return;
            }
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Invalid date format"}');
            return;
        }

   
        List<ContentVersion> contentVersions = [SELECT Id,Title, ContentDocumentId, VersionData 
                                                FROM ContentVersion 
                                                WHERE CreatedDate >= :fromDate 
                                                AND CreatedDate <= :toDate limit 120];

       
        List<Map<String, Object>> responseList = new List<Map<String, Object>>();
        for (ContentVersion cv : contentVersions) {
            Map<String, Object> contentMap = new Map<String, Object>();
            contentMap.put('Id', cv.Id);
            contentMap.put('FileName', cv.Title);
            contentMap.put('ContentDocumentId', cv.ContentDocumentId);
           // contentMap.put('VersionData', cv.VersionData);
            contentMap.put('VersionData', cv.VersionData != null ? EncodingUtil.base64Encode(cv.VersionData) : null);
            responseList.add(contentMap);
        }

        
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serializePretty(responseList));
    }
}