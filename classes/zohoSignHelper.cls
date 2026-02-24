public class zohoSignHelper {
    public static void dummyMethod(){
        
    }
/*
    Public static string getAccesstoken(){
        
        String clientId = '';
        String clientSecret = '';
        String refToken = '';
        String grantType = '';
        String redirectUri = '';
        String Endpoint = '';
        string AccessToken = '';
        
        List<ZohoSign__mdt> zohoMdtList =[SELECT Id, DeveloperName, Client_Secret__c, Client_Id__c, refresh_token__c, code__c, Endpoint__c, grant_type__c, redirect_uri__c FROM ZohoSign__mdt where DeveloperName = 'Access_token'];
        
        for(ZohoSign__mdt  zmd : zohoMdtList){
            clientId = zmd.Client_Id__c;
            clientSecret = zmd.Client_Secret__c;
            refToken = zmd.refresh_token__c;
            grantType = zmd.grant_type__c;
            redirectUri = zmd.redirect_uri__c;
            Endpoint = zmd.Endpoint__c; 
        }
        
        String endpointUrl = Endpoint + 
                                        'refresh_token=' + EncodingUtil.urlEncode(refToken, 'UTF-8') + 
                                        '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') + 
                                        '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') + 
                                        '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8') + 
                                        '&grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8');
                                        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
       try {
            HttpResponse response = http.send(request);
           
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
                
                ZohoSignGetAccessTokenWrapper resWrap = ZohoSignGetAccessTokenWrapper.parse(response.getBody());
                system.debug('resWrap'+ resWrap);
                
                if(resWrap != Null){
                    AccessToken = resWrap.access_token;
                    system.debug('AccessToken@@' + AccessToken);
                }else{
                    AccessToken = '';
                }
               
            } else {
               
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
           
        } catch (Exception e) {
         
            System.debug('Exception: ' + e.getMessage());
        }
         return AccessToken;
    }
    
    @InvocableMethod
    Public static void CreateDocument(List<Id> quoteID){
        String accessToken = getAccessToken(); 
        string  signActionID ='';
        string inpersonActionId = '';
        string requestName ='';  
        
     
        
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
        
         Set<Id> opportunityIds = new Set<Id>();
        
        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Opportunity2__c  FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c  != null AND ID =:quoteID];
        
        for(SBQQ__Quote__c qt : quotes){
            opportunityIds.add(qt.SBQQ__Opportunity2__c);
        } 
        
        OpportunityContactRole oppContRoleList =[SELECT Id, ContactId, OpportunityId, Role,contact.name,contact.email,contact.phone FROM OpportunityContactRole where Role ='Authorised Signatory' AND OpportunityId IN:opportunityIds LIMIT 1]; 
        string recEmail = oppContRoleList.contact.email;
        string recName = oppContRoleList.contact.name;
        
        Id currentUserId = UserInfo.getUserId();
        user u =[select id, name,email FROM user where ID = :currentUserId LIMIT 1];
        string userEmail = u.email;
        string username = u.Name;
        
         String jsonPayload = '{"requests": {' +
                                            '"request_name": "'+ConVer.Title+' ",' +
                                            '"actions": [' +
                                                '{' +
                                                    '"action_type": "SIGN",' +
                                                    '"recipient_email": "'+oppContRoleList.contact.email+'",' +
                                                    '"recipient_name": "'+oppContRoleList.contact.name+'",' +
                                                    '"signing_order": 0,' +
                                                    '"verify_recipient": false,' +
                                                    '"verification_type": "",' +
                                                    '"verification_code": "",' +
                                                    '"private_notes": "To be signed"' +
                                                '},' +
                                                '{' +
                                                    '"action_type": "INPERSONSIGN",' +
                                                    '"recipient_email": "krishnanand.bastikar@bvcbrinks.com",' +   // krishna bastikar email-krishnanand.bastikar@bvcbrinks.com 
                                                    '"recipient_name": "'+u.Name+'",' +                                // current user name
                                                    '"in_person_name": "krishnanand Bastikar",' +                           // krishna bastikar name
                                                    '"in_person_email": "'+u.Email+'",' +        //current user Email 
                                                    '"signing_order": 1,' +
                                                    '"verify_recipient": false,' +
                                                    '"private_notes": "Sign as Inperson"' +
                                                '}' +
                                            '],' +
                                            '"expiration_days": 10,' +
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
                        
                        List<SBQQ__Quote__c> qtList = [SELECT Id, Name, SBQQ__Account__c,Business_Type__c, Account_Name__c, Account_Email_ID__c, DocumentId__c, RequestId__c FROM SBQQ__Quote__c where Id =:quoteId ];
                          
                        List<SBQQ__Quote__c> updateQtList = new List<SBQQ__Quote__c>();
                        
                        for(SBQQ__Quote__c qt : qtList){   
                            qt.DocumentId__c = documentId;
                            qt.RequestId__c = requestId;
                            businessType = qt.Business_Type__c;
                            updateQtList.add(qt);
                        }
                             
                        update updateQtList;
                    }
                    
                }
                 
               updateDocument(accessToken,documentId,requestId,requestName,recEmail,recName,userEmail,username,inpersonActionId,signActionID,quoteID,pages,businessType);
                
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
   @Future(callout=true)
    public static void updateDocument(string accessToken ,string documentId,string requestId,string requestName,string recEmail,string recName,string userEmail,string username,string inpersonActionId,string signActionId,List<id>quoteID,integer pages,string businessType){
      
   
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
                            '          {' +
                            '            "field_name": "Signature",' +
                            '            "field_label": "Signature",' +
                            '            "field_type_name": "Signature",' +
                            '            "document_id": "'+documentId+'",' +
                            '            "action_id": "'+signActionId+'",' +
                            '            "is_mandatory": true,' +
                            '            "x_coord": 370,' +
                            '            "y_coord": 100,' +
                            '            "abs_width": 70,' +
                            '            "abs_height": 30,' +
                            '            "page_no": '+pages+',' +
                            '            "is_resizable": true,' +
                            '            "is_draggable": true,' +
                            '            "description_tooltip": "Add your signature"' +
                            '          }' +
                            '        ]' +
                            '      }' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionId+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "recipient_email": "krishnanand.bastikar@bvcbrinks.com",' +
                            '      "recipient_name": "'+username+' ",' +
                            '      "in_person_name": "krishnanand Bastikar",' +
                            '      "in_person_email": "'+userEmail+'",' +
                             '  "signing_order": 1,' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                            '          {' +
                            '            "field_name": "Signature",' +
                            '            "field_label": "Signature",' +
                            '            "field_type_name": "Signature",' +
                            '            "document_id": "'+documentId+'",' +
                            '            "action_id": "'+inpersonActionId+'",' +
                            '            "is_mandatory": true,' +
                            '            "x_coord": 100,' +
                            '            "y_coord": 100,' +
                            '            "abs_width": 70,' +
                            '            "abs_height": 30,' +
                            '            "page_no":'+pages+',' +
                            '            "is_resizable": true,' +
                            '            "is_draggable": true,' +
                            '            "description_tooltip": "Add your signature"' +
                            '          }' +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';

// NOn ACR payload:


        system.debug('request@@'+jsonPayload);
        string urlEncodedBody1 = 'data=' + EncodingUtil.urlEncode(jsonPayload, 'UTF-8');
        
          String jsonPayload1 = '{' +
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
                            '          {' +
                            '            "field_name": "Signature",' +
                            '            "field_label": "Signature",' +
                            '            "field_type_name": "Signature",' +
                            '            "document_id": "'+documentId+'",' +
                            '            "action_id": "'+signActionId+'",' +
                            '            "is_mandatory": true,' +
                            '            "x_coord": 520,' +
                            '            "y_coord": 460,' +
                            '            "abs_width": 70,' +
                            '            "abs_height": 30,' +
                            '            "page_no": '+pages+',' +
                            '            "is_resizable": true,' +
                            '            "is_draggable": true,' +
                            '            "description_tooltip": "Add your signature"' +
                            '          }' +
                            '        ]' +
                            '      }' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionId+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "recipient_email": "krishnanand.bastikar@bvcbrinks.com",' +
                            '      "recipient_name": "'+username+' ",' +
                            '      "in_person_name": "krishnanand Bastikar",' +
                            '      "in_person_email": "'+userEmail+'",' +
                             '  "signing_order": 1,' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                            '          {' +
                            '            "field_name": "Signature",' +
                            '            "field_label": "Signature",' +
                            '            "field_type_name": "Signature",' +
                            '            "document_id": "'+documentId+'",' +
                            '            "action_id": "'+inpersonActionId+'",' +
                            '            "is_mandatory": true,' +
                            '            "x_coord": 170,' +
                            '            "y_coord": 460,' +
                            '            "abs_width": 70,' +
                            '            "abs_height": 30,' +
                            '            "page_no":'+pages+',' +
                            '            "is_resizable": true,' +
                            '            "is_draggable": true,' +
                            '            "description_tooltip": "Add your signature"' +
                            '          }' +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
        
        system.debug('request@@'+jsonPayload1);
        string urlEncodedBody2 = 'data=' + EncodingUtil.urlEncode(jsonPayload1, 'UTF-8');
 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        if(businessType == 'ACR'){
              request.setBody(urlEncodedBody1);
        }else{
            request.setBody(urlEncodedBody2);
        }
      
        try{
               HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                 System.debug('Response: ' + response.getBody());
                
                 sendDocumentToSign(accessToken,requestID,DocumentID,signActionId,inpersonActionId,quoteID);
                
            }else{
               System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                
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
                            '      "action_type": "INPERSONSIGN"' +
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
                   
                 List<SBQQ__Quote__c> qtList = [SELECT Id, Name, SBQQ__Account__c, Account_Name__c, Account_Email_ID__c, DocumentId__c, RequestId__c FROM SBQQ__Quote__c where Id =:quoteID ];
                          
                        List<SBQQ__Quote__c> updateQuoteList = new List<SBQQ__Quote__c>();
                        
                        for(SBQQ__Quote__c qt : qtList){   
                            qt.SBQQ__Status__c = 'Contract Sent';
                            updateQuoteList.add(qt);
                        }
                              
                        update updateQuoteList;
                
            }else{
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                
            }
            
        }catch(exception e){
            system.debug('Error:'+e.getMessage());
        }
        
    }
    */
  
}