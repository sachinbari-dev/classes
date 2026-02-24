@RestResource(urlMapping='/AttachmentDataAPI/*')
global class getAttachmentObjectData {
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

       List<Attachment> attachs = [SELECT Id, Body, ParentId, Name FROM Attachment  
                                  WHERE CreatedDate >= :fromDate 
                                  AND CreatedDate <= :toDate ];
      

       
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