@RestResource(urlMapping='/AttachmentRecordAPI/*')
global class getAttachmentRecordById {
    @HttpPost 
    global static void getInvoiceData() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

        
       List<Object> linkedEntityIdsRaw  = (List<Object>) payload.get('parentIds');

       List<String> parentIds = new List<String>();
        if (linkedEntityIdsRaw != null) {
            for (Object id : linkedEntityIdsRaw) {
                parentIds.add(String.valueOf(id));
            }
        }
        
      
        if (parentIds == null || parentIds.isEmpty()) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"No ParentIDs provided"}');
            return;
        }
 
          List<Attachment> attachs = [SELECT Id, Body, ParentId, Name FROM Attachment  
                                      WHERE ParentId IN :parentIds];
                                      
      
           List<Map<String, Object>> responseList = new List<Map<String, Object>>();
                for (Attachment at : attachs) {
                    Map<String, Object> attachMap = new Map<String, Object>();
                    attachMap.put('AttachmentId', at.Id);
                    attachMap.put('FileName', at.Name);
                    attachMap.put('ParentId', at.ParentId);
                    attachMap.put('Body', at.Body != null ? EncodingUtil.base64Encode(at.Body) : null);
                    responseList.add(attachMap);
                }
           
       
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serializePretty(responseList));
    }
}