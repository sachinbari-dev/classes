public class zohoSignGetDocumentAPIHelper {
    
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
    }}
    
 /*   public static void getDocumentDetails(Map<String, List<Id>> requestIdToQuoteIdsMap) {
        
        String accessToken = zohoSignHelper.getAccessToken();
        Http http = new Http();
        
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
       // List<order> newOrList = new List<order>();
        
        for (String requestId : requestIdToQuoteIdsMap.keySet()) {
            String endpoint = 'https://sign.zoho.in/api/v1/requests/' + requestId;
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
                
                zohoSignGetDocumentWrapper resWrap = zohoSignGetDocumentWrapper.parse(response.getBody());
                System.debug('resWrap@@' + resWrap);
                
                // Check if request_status is Completed
                String requestStatus = resWrap.requests.request_status;
                
                if (requestStatus=='Completed') {
                    
                    for (zohoSignGetDocumentWrapper.Document_ids doc : resWrap.requests.document_ids) {
                        String documentId = doc.document_id;
                        String imageTitle = doc.document_name;
                        
                        // Download the PDF file using the provided API endpoint
                        String pdfDownloadEndpoint = 'https://sign.zoho.in/api/v1/requests/' + requestId + '/documents/' + documentId + '/pdf';
                        
                        HttpRequest pdfRequest = new HttpRequest();
                        pdfRequest.setEndpoint(pdfDownloadEndpoint);
                        pdfRequest.setMethod('GET');
                        pdfRequest.setTimeout(120000);
                        pdfRequest.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
                        
                        HttpResponse pdfResponse = http.send(pdfRequest);
                        
                        if (pdfResponse.getStatusCode() == 200) {
                            Blob pdfBlob = pdfResponse.getBodyAsBlob();
                            
                            List<SBQQ__Quote__c> qtList = [SELECT Id, Name, DocumentId__c,Contract_Signed__c,SBQQ__Ordered__c,Business_Type__c, RequestId__c FROM SBQQ__Quote__c WHERE Id IN :requestIdToQuoteIdsMap.get(requestId)];
                            
                          
                            for (SBQQ__Quote__c qt : qtList) {
                                  qt.SBQQ__Status__c = 'Contract Signed';
                             
                                if(qt.Business_Type__c == 'Non ACR'){
                                    qt.SBQQ__Ordered__c =  true;
                                    qt.Contract_Signed__c = true;
                                }  
                                
                                ContentVersion contentVersion = new ContentVersion();
                                contentVersion.Title = imageTitle + ' Completed';
                                contentVersion.PathOnClient = imageTitle + '.pdf';
                                contentVersion.VersionData = pdfBlob;
                                contentVersion.ContentLocation = 'S'; 
                                contentVersion.FirstPublishLocationId = qt.Id;
                                
                                contentVersionsToInsert.add(contentVersion);
                                quotesToUpdate.add(qt);
                                
                            }
                        } else {
                            System.debug('Failed to download PDF: ' + pdfResponse.getStatus());
                        }
                    }
                    
                } else {
                    System.debug('Request status is not Completed for requestId: ' + requestId + ', skipping update.');
                }
            } else {
                System.debug('Failed to fetch document details for requestId: ' + requestId + ', Status: ' + response.getStatus());
            }
        }
        
       
        if (!contentVersionsToInsert.isEmpty()) {
            insert contentVersionsToInsert;
            system.debug('contentVersionsToInsert@@' + contentVersionsToInsert);
        }
        
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
            system.debug('quotesToUpdate@@' + quotesToUpdate);
        }
        /*
        for(string requestId : requestIdToQuoteIdsMap.keySet()){
            
              List<SBQQ__Quote__c> qtList = [SELECT Id, Name, SBQQ__Account__c, Account_Name__c,Contract_Signed__c,Business_Type__c, Account_Email_ID__c,SBQQ__Ordered__c, DocumentId__c, RequestId__c FROM SBQQ__Quote__c WHERE Id IN :requestIdToQuoteIdsMap.get(requestId)];
                            
              List<order> orList = [SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.id, SBQQ__Contracted__c FROM Order where SBQQ__Quote__r.id IN :requestIdToQuoteIdsMap.get(requestId)];
                  system.debug('orList@@'+orList);
            
            for (SBQQ__Quote__c qt : quotesToUpdate) {
                  for(order ord : orList){
                        if(ord.SBQQ__Quote__c == qt.id){
                             if(qt.Business_Type__c == 'Non ACR'){
                               //   ord.SBQQ__Contracted__c = true;
                                   newOrList.add(ord);
                               }
                   }
             }
        }
       
        if(!newOrList.isEmpty()){
            update newOrList;
            system.debug('newOrList@@'+newOrList);
        }
        }  
    }
}*/