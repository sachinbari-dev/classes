public class BVC_BrinksZohoSignHelper {

     @InvocableMethod
    Public static void CreateDocument(List<Id> quoteID){
        
        
          Zoho_Access_Token__c AccToken = [ SELECT Name, Access_Token__c, Id FROM Zoho_Access_Token__c];
        
        String accessToken = AccToken.Access_Token__c; 
        string  signActionID ='';
        string inpersonActionId = '';
        string requestName ='';  
        string inSignerName = '';
        string inSignerEmail = '';
        
        List<In_Sign_Person_Email__mdt> inSignerMDTList = [SELECT Signer_Name__c, Email__c, Id, DeveloperName FROM In_Sign_Person_Email__mdt where  DeveloperName=:'brinks_Insigner' LIMIT 1];
     
        for(In_Sign_Person_Email__mdt  Ins : inSignerMDTList){
            inSignerName = Ins.Signer_Name__c;
            inSignerEmail = Ins.Email__c;
        }
        
        List<ContentDocumentLink> ContDocLink = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType FROM ContentDocumentLink where LinkedEntityId =:quoteID];
        
        set<id> contentDocId = new set<id>();
        
            if(!ContDocLink.isEmpty()){
                for(ContentDocumentLink link : ContDocLink){
                    contentDocId.add(link.ContentDocumentId);
                }
            }
        
        set<id> contId = new set<id>();
        List<ContentDocument> contDocList = [SELECT Title, Id, LatestPublishedVersionId, ParentId, CreatedDate FROM ContentDocument where ID IN :contentDocId ORDER BY CreatedDate DESC LIMIT 1];
        
            if(!contDocList.isEmpty()){
                for(ContentDocument cd: contDocList){
                contId.add(cd.id);
               }
            }
        
        ContentVersion ConVer = [SELECT Id, Title,PathOnClient , ContentDocumentId, VersionData, FirstPublishLocationId FROM ContentVersion where ContentDocumentId IN :contId];
        String fileBody = EncodingUtil.base64Encode(ConVer.VersionData);
        System.debug('filebody: ' + fileBody);
        
                
       BVC_bulk_Agreement_signing__c  bulkList = [select id,name,BVC_Brink_s_Office_Address__c, Customer_Address__c, Customer_GST_No__c, Customer_IEC_No__c, 
                             Customer_Name__c,Customer_Name__r.name, You_are__c,Signatory__c, Customer_Email__c, Document_Type__c from BVC_bulk_Agreement_signing__c where id IN:quoteID LIMIT 1];
        
        string recEmail = bulkList.Customer_Email__c;
        string recName = bulkList.Signatory__c;
        system.debug('recEmail'+ recEmail);
        system.debug('recName'+ recName);
       
        
        Id currentUserId = UserInfo.getUserId();
        user u =[select id, name,email FROM user where ID = :currentUserId LIMIT 1];
        string userEmail = u.email;
        string username = u.Name;
        
         String jsonPayload = '{"requests": {' +
                                            '"request_name": "'+ConVer.Title+' ",' +
                                            '"actions": [' +
                                                '{' +
                                                    '"action_type": "SIGN",' +
                                                    '"recipient_email": "'+bulkList.Customer_Email__c+'",' +
                                                    '"recipient_name": "'+bulkList.Signatory__c+'",' +
                                                    '"signing_order": 0,' +
                                                    '"verify_recipient": false,' +
                                                    '"verification_type": "",' +
                                                    '"verification_code": "",' +
                                                    '"private_notes": "To be signed"' +
                                                '},' +
                                                '{' +
                                                    '"action_type": "INPERSONSIGN",' +
                                                    '"recipient_email": "'+inSignerEmail+'",' +   // krishna bastikar email-krishnanand.bastikar@bvcbrinks.com 
                                                    '"recipient_name": "'+u.Name+'",' +                                // current user name
                                                    '"in_person_name": "'+inSignerName+'",' +                           // krishna bastikar name
                                                    '"in_person_email": "'+u.Email+'",' +        //current user Email 
                                                    '"signing_order": 1,' +
                                                    '"verify_recipient": false,' +
                                                    '"private_notes": "Sign as Inperson"' +
                                                '}' +
                                            '],' +
                                            '"expiration_days": 30,' +
                                            '"is_sequential": true,' +
                                            '"email_reminders": true,' +
                                            '"reminder_period": 0' +
                                        '}}';

 
         
        System.debug('JSON Payload: ' + jsonPayload);

        string documentId = '';
        string requestId = '';
        string ActionID= '';
        integer pages = Null;
        string businessType = '';
        string BVCservice = '';
        
        String endpointUrl = 'https://sign.zoho.in/api/v1/requests';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);

        // Define boundary and body parts
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String closeDelimiter = '\r\n--' + boundary + '--\r\n';

        // Construct data part
        String metadataPart = delimiter +
                              'Content-Disposition: form-data; name="data"\r\n' +
                              'Content-Type: application/json\r\n\r\n' +
                              jsonPayload + '\r\n';

        // Construct file part
        String filePart = delimiter +
                          'Content-Disposition: form-data; name="file"; filename="' + conVer.PathOnClient + '"\r\n' +
                          'Content-Type: application/octet-stream\r\n\r\n';

        // Convert parts to Blob
        Blob metadataBlob = Blob.valueOf(metadataPart);
        Blob fileHeaderBlob = Blob.valueOf(filePart);
        Blob fileBlob = conVer.VersionData;
        Blob closeDelimiterBlob = Blob.valueOf(closeDelimiter);

        // Combine parts into a single Blob
        List<Blob> bodyParts = new List<Blob>{ metadataBlob,fileHeaderBlob, fileBlob, closeDelimiterBlob};
        Blob requestBodyBlob = Blob.valueOf('');
        
        for (Blob part : bodyParts) {
            requestBodyBlob = Blob.valueOf(requestBodyBlob.toString() + EncodingUtil.convertToHex(part));
        }
        
        requestBodyBlob = EncodingUtil.convertFromHex(requestBodyBlob.toString());

        // Set request properties
        request.setHeader('Content-Type', 'multipart/form-data; boundary="' + boundary + '"');
        request.setBodyAsBlob(requestBodyBlob);

        // Send HTTP request and handle response
        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('Request created successfully');
                System.debug('Response: ' + response.getBody());
                
                zohoSignCreateDocumentWrapper resWrap =  zohoSignCreateDocumentWrapper.parse( response.getBody());
                
                if (resWrap != null && resWrap.requests != null) {
                    requestId = resWrap.requests.request_id;
                    system.debug('requestID' + requestId);
                    
                    if (resWrap.requests.document_ids != null && !resWrap.requests.document_ids.isEmpty()) {
                        documentId = resWrap.requests.document_ids[0].document_id;
                        system.debug('documentId'+ documentId);
                    }
                    
                    if(resWrap.requests.actions !=Null && !resWrap.requests.actions.isEmpty()){
                        ActionID = resWrap.requests.actions[0].action_id;
                         system.debug('ActionID'+ ActionID);
                    }
                    
                     if (resWrap.requests != null && resWrap.requests.actions != null && resWrap.requests.actions.size() >= 2) {   
                            inpersonActionId = resWrap.requests.actions.get(0).action_id;
                            signActionID = resWrap.requests.actions.get(1).action_id;
                            requestName = resWrap.requests.request_name;
                            pages = resWrap.requests.document_ids[0].total_pages-1;
                            system.debug('inPersonaction'+inpersonActionId );
                            system.debug('signActionID'+signActionID );
                            system.debug('pages@@'+pages);
                   }
                    
                    if(requestId != Null && documentId != Null){
                        
                        List<BVC_bulk_Agreement_signing__c> qtList = [SELECT Id, Name, DocumentId__c, RequestId__c FROM BVC_bulk_Agreement_signing__c where Id =:quoteId ];
                          
                        List<BVC_bulk_Agreement_signing__c> updateQtList = new List<BVC_bulk_Agreement_signing__c>();
                        
                        for(BVC_bulk_Agreement_signing__c qt : qtList){   
                            qt.DocumentId__c = documentId;
                            qt.RequestId__c = requestId;
                           
                            updateQtList.add(qt);
                        }
                              
                        update updateQtList;
                    }
                    
                }
                 
               updateDocument(accessToken,documentId,requestId,requestName,recEmail,recName,userEmail,username,inpersonActionId,signActionID,quoteID,pages,businessType,inSignerName,inSignerEmail,BVCservice);
                
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                 for(ID bv : quoteId){
                    integration_Log__c intlg = new integration_Log__c();
                      intlg.BVC_bulk_Agreement_signing__c = bv;
                      intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c = 'brinks Agreement :' + response.getBody();
                      intlg.ZohoAPIName__c = 'Create Document API Error'; 
                        insert intlg;
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

    }
      @Future(callout=true)
    public static void updateDocument(string accessToken ,string documentId,string requestId,string requestName,string recEmail,string recName,string userEmail,string username,string inpersonActionId,string signActionId,List<id>quoteID,integer pages,string businessType,string inSignerName,string inSignerEmail,string BVCservice){
      
         string endpointUrl = 'https://sign.zoho.in/api/v1/requests/'+requestId;
        
         String jsonPayload = '{' +
                            '"requests": {' +
                            '  "request_name": "'+requestName+'",' + 
                            '  "actions": [' +
                            '    {' +
                            '      "action_id": "'+signActionId+'",' +
                            '      "recipient_name": "'+recName+'",' +
                            '  "signing_order": 0,' +
                            '      "recipient_email": "'+recEmail+'",' +
                            '      "action_type": "SIGN",' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                                    getBrinksImageFields(signActionId, documentId, 370, 685, 70, 30, pages) + 
                            '        ]' +
                            '      }' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionId+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+' ",' +
                            '      "in_person_name": "'+inSignerName+'",' +
                            '      "in_person_email": "'+userEmail+'",' +
                             '  "signing_order": 1,' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                                     getBrinksImageFields(signActionId, documentId, 70, 600, 70, 30, pages) +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
         system.debug('request@@'+jsonPayload);
        string urlEncodedBody1 = 'data=' + EncodingUtil.urlEncode(jsonPayload, 'UTF-8');
        
          Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
         request.setBody(urlEncodedBody1);
      
        try{
               HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                 System.debug('Response: ' + response.getBody());
                
                sendDocumentToSign(accessToken,requestID,DocumentID,signActionId,inpersonActionId,quoteID);
                
            }else{
               System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                for(ID bv : quoteId){
                    integration_Log__c intlg = new integration_Log__c();
                      intlg.BVC_bulk_Agreement_signing__c = bv;
                      intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c = 'brinks Agreement :' + response.getBody();
                      intlg.ZohoAPIName__c = 'update Document API Error'; 
                        insert intlg;
                }
                
                
          }
        
        }catch(exception e){
            system.debug('Error:'+e.getMessage());
        }
    }
    
     public static void sendDocumentToSign(string accessToken,string requestID,string DocumentID,String actionId,string inpersonActionID,List<id>quoteID){
        
        string endpointUrl = 'https://sign.zoho.in/api/v1/requests/'+requestID+'/submit';
        system.debug('endpoint@@@' + endpointUrl);
        
       
       String jsonPayload = '{' +
                            '"requests": {' +
                            '  "actions": [' +
                            '    {' +
                            '      "action_id": "'+actionId+'",' +
                            '      "action_type": "SIGN"' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionID+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "in_person_name": "krishnanand Bastikar"' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';


        String urlEncodedBody = 'data=' + EncodingUtil.urlEncode(jsonPayload, 'UTF-8');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedBody);
         
        try{
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                System.debug('Response: ' + response.getBody());
                   
                 List<BVC_bulk_Agreement_signing__c> qtList = [SELECT Id, Name,status__c, DocumentId__c, RequestId__c FROM BVC_bulk_Agreement_signing__c where Id =:quoteID ];
                          
                        List<BVC_bulk_Agreement_signing__c> updateQuoteList = new List<BVC_bulk_Agreement_signing__c>();
                        
                        for(BVC_bulk_Agreement_signing__c qt : qtList){   
                            qt.status__c = 'Contract Sent';
                            updateQuoteList.add(qt);
                        }
                              
                        update updateQuoteList;
                
            }else{
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                for(ID bv : quoteId){
                    integration_Log__c intlg = new integration_Log__c();
                      intlg.BVC_bulk_Agreement_signing__c = bv;
                      intlg.Status_Code__c = String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c ='brinks Agreement :'+  response.getBody();
                      intlg.ZohoAPIName__c = 'Send Document for signature API Error'; 
                        insert intlg;
                }
                
                
            }
            
        }catch(exception e){
            system.debug('Error:'+e.getMessage());
        }
        
    }
    
    
       public static String getBrinksImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
         
           List<String> imageFieldsList = new List<String>();
            for (Integer i = 0; i <= totalPages; i++) {
                if(i == 0){
                    imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+665+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                 );
                }
                if(i == 1){
                          imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+685+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                  if(i == 2){
                          imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+695+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                
                   if(i == 3){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+685+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                
                 if(i == 4){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+705+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i == 5){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+685+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i == 6){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+685+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i == 7){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+689+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i == 8){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+600+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
              
                }
            return String.join(imageFieldsList, ',');
         
            }
}