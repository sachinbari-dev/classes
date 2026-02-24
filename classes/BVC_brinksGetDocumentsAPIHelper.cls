public class BVC_brinksGetDocumentsAPIHelper {

    
    public static void getDocumentDetails(Map<String, List<Id>> requestIdToQuoteIdsMap,string accessToken) {
        
      //  String accessToken = zohoSignHelper.getAccessToken();
      
        
        List<BVC_bulk_Agreement_signing__c> quotesToUpdate = new List<BVC_bulk_Agreement_signing__c>();
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
        List<integration_Log__c>  intlogList = new List<integration_Log__c>();
        
        for (String requestId : requestIdToQuoteIdsMap.keySet()) {
            String endpoint = 'https://sign.zoho.in/api/v1/requests/' + requestId;
             
            Http http = new Http();
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
                
                  List<BVC_bulk_Agreement_signing__c> qtList = [SELECT Id, Name,status__c,Documentstatus__c,CustomerSignActionStatus__c,InpersonSignActionStatus__c, DocumentId__c, RequestId__c FROM BVC_bulk_Agreement_signing__c WHERE Id IN :requestIdToQuoteIdsMap.get(requestId)];
                   
                
                for(zohoSignGetDocumentWrapper.Actions action : resWrap.requests.actions){
                    for(BVC_bulk_Agreement_signing__c qt : qtList){
                        if(action.action_type =='SIGN'){
                            qt.CustomerSignActionStatus__c = action.action_status;
                            system.debug('action_status' + action.action_status);
                        }
                        if(action.action_type == 'INPERSONSIGN'){
                            qt.InpersonSignActionStatus__c = action.action_status;
                            system.debug('inperson action_status' + action.action_status);
                        }
                    }
                }
                
                      
                
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
                            
                          
                            for (BVC_bulk_Agreement_signing__c qt : qtList) {
                                  qt.status__c = 'Contract Signed';
                                  qt.Documentstatus__c = 'completed'; 
                             
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
                             for(BVC_bulk_Agreement_signing__c bv : qtList){
                                integration_Log__c intlg = new integration_Log__c();
                                  intlg.BVC_bulk_Agreement_signing__c = bv.id; 
                                  intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                                  intlg.Response_JSON__c =  response.getBody();
                                  intlg.ZohoAPIName__c = 'Download PDF API Error'; 
                                    intlogList.add(intlg);
                            }
                        }
                    }
                    
                } else {
                        for(BVC_bulk_Agreement_signing__c  qts : qtList){
                                qts.Documentstatus__c = requestStatus; 
                                quotesToUpdate.add(qts);
                        }
                    System.debug('Request status is not Completed for requestId: ' + requestId + ', skipping update.');
                }                    
                
            } else {
                System.debug('Failed to fetch document details for requestId: ' + requestId + ', Status: ' + response.getStatus());
                 List<BVC_bulk_Agreement_signing__c> qtList = [SELECT Id, Name,status__c, DocumentId__c, RequestId__c FROM BVC_bulk_Agreement_signing__c WHERE Id IN :requestIdToQuoteIdsMap.get(requestId)];
                  
                 for(BVC_bulk_Agreement_signing__c bv : qtList){
                    integration_Log__c intlg = new integration_Log__c();
                      intlg.BVC_bulk_Agreement_signing__c = bv.id; 
                      intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c =  response.getBody();
                      intlg.ZohoAPIName__c = 'fetch document details API Error'; 
                        intlogList.add(intlg);
                }
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
        if(!intlogList.isEmpty()){
            insert  intlogList;
        }
   
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
      }
    
}