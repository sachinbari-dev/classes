public class BVC_zohoSignHelper {

    
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
                    
                    Zoho_Access_Token__c AccToken = [ SELECT Name, Access_Token__c, Id FROM Zoho_Access_Token__c];
                    AccToken.Access_Token__c = AccessToken;
                    
                    update AccToken;
                    
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
        
          Zoho_Access_Token__c AccToken = [ SELECT Name, Access_Token__c, Id FROM Zoho_Access_Token__c];
        
        String accessToken = AccToken.Access_Token__c; 
        string  signActionID ='';
        string inpersonActionId = '';
        string requestName ='';  
        string inSignerName = '';
        string inSignerEmail = '';
        
        List<In_Sign_Person_Email__mdt> inSignerMDTList = [SELECT Signer_Name__c, Email__c, Id, DeveloperName FROM In_Sign_Person_Email__mdt where  DeveloperName=:'InSigner_Email' LIMIT 1];
     
        for(In_Sign_Person_Email__mdt  Ins : inSignerMDTList){
            inSignerName = Ins.Signer_Name__c;
            inSignerEmail = Ins.Email__c;
        }
        /*
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
         */
                    
                    List<ContentDocumentLink> ContDocLink = [
                SELECT Id, ContentDocumentId, LinkedEntityId, ShareType 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :quoteID
            ];
            
            Set<Id> contentDocId = new Set<Id>();
            for(ContentDocumentLink link : ContDocLink){
                contentDocId.add(link.ContentDocumentId);
            }
        
        List<BVCQuote__c> quoteList = [ SELECT Id, Name, BVC_Service__c, Business_Type__c  FROM BVCQuote__c  WHERE Id IN :quoteID];
            Set<String> eshipQuoteIds = new Set<String>();
            Set<String> otherQuoteIds = new Set<String>();
            
            for (BVCQuote__c qt : quoteList) {
                if (qt.BVC_Service__c == 'eSHIP') {
                    eshipQuoteIds.add(qt.Id);
                } else {
                    otherQuoteIds.add(qt.Id);
                }
            }
        List<ContentDocument> contDocList = new List<ContentDocument>();
            
            if (!eshipQuoteIds.isEmpty()) {
                contDocList.addAll([
                    SELECT Title, Id, LatestPublishedVersionId, FileExtension, CreatedDate 
                    FROM ContentDocument 
                    WHERE Id IN :contentDocId
                      AND FileExtension = 'pdf'
                      AND Title LIKE '%Quote Quotation%'
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ]);
            }
            
            if (!otherQuoteIds.isEmpty()) {
                contDocList.addAll([
                    SELECT Title, Id, LatestPublishedVersionId, FileExtension, CreatedDate 
                    FROM ContentDocument 
                    WHERE Id IN :contentDocId
                      AND FileExtension = 'pdf'
                      AND Title LIKE '%Order Form%'
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ]);
            }
        /*
            List<ContentDocument> contDocList = [
                SELECT Title, Id, LatestPublishedVersionId, FileExtension, CreatedDate 
                FROM ContentDocument 
                WHERE Id IN :contentDocId 
                  AND FileExtension = 'pdf'
                 AND Title LIKE '%Order Form%'
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];
*/
            
            Set<Id> contId = new Set<Id>();
            for(ContentDocument cd : contDocList){
                contId.add(cd.Id);
            }
            
            ContentVersion ConVer = [
                SELECT Id, Title, PathOnClient, ContentDocumentId, VersionData, FileExtension, FirstPublishLocationId
                FROM ContentVersion
                WHERE ContentDocumentId IN :contId
                  AND FileExtension = 'pdf'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            String fileBody = EncodingUtil.base64Encode(ConVer.VersionData);
            System.debug('PDF filebody: ' + fileBody);

              
        People_Role__c  peopleList=[SELECT Role__c, BVCQuote__c, People__r.Name, People__r.Email, Name, BVCQuote__r.Id, Id FROM People_Role__c WHERE Role__c = 'Authorized Signatory' AND BVCQuote__r.Id  IN :quoteId];
        string recEmail = peopleList.People__r.Email;
        string recName = peopleList.People__r.Name;
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
                                                    '"recipient_email": "'+peopleList.People__r.Email+'",' +
                                                    '"recipient_name": "'+peopleList.People__r.Name+'",' +
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
                        
                        List<BVCQuote__c> qtList = [SELECT Id, Name,Business_Type__c,BVC_Service__c, DocumentId__c, RequestId__c FROM BVCQuote__c where Id =:quoteId ];
                          
                        List<BVCQuote__c> updateQtList = new List<BVCQuote__c>();
                        
                        for(BVCQuote__c qt : qtList){   
                            qt.DocumentId__c = documentId;
                            qt.RequestId__c = requestId;
                            businessType = qt.Business_Type__c;
                            BVCservice = qt.BVC_Service__c;
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
                      intlg.BVCQuote__c = bv;
                      intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c =  response.getBody();
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
                                    getACRImageFields(signActionId, documentId, 590, 500, 70, 30, pages) + 
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
                                     getACRImageFields(signActionId, documentId, 130, 500, 70, 30, pages) +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
        /*
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
                            '            "x_coord": 530,' +
                            '            "y_coord": 500,' +
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
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+' ",' +
                            '      "in_person_name": "'+inSignerName+'",' +
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
                            '            "y_coord": 500,' +
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
   */
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
                                       getNonACRImageFields(signActionId, documentId, 590, 500, 70, 30, pages) + 
                            '        ]' +
                            '      }' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionId+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+'",' +
                            '      "in_person_name": "'+inSignerName+'",' +
                            '      "in_person_email": "'+userEmail+'",' +
                             '  "signing_order": 1,' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                                     getNonACRImageFields(signActionId, documentId, 130, 500, 70, 30, pages) + 
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
        /*
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
                            '            "x_coord": 530,' +
                            '            "y_coord": 500,' +
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
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+'",' +
                            '      "in_person_name": "'+inSignerName+'",' +
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
                            '            "y_coord": 500,' +
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
        */
        
        system.debug('request@@'+jsonPayload1);
        string urlEncodedBody2 = 'data=' + EncodingUtil.urlEncode(jsonPayload1, 'UTF-8');
        
 //eship payload
        
             String jsonPayload2 = '{' +
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
                                       getEshipImageFields(signActionId, documentId, 420, 690, 70, 30, pages) + 
                            '        ]' +
                            '      }' +
                            '    },' +
                            '    {' +
                            '      "action_id": "'+inpersonActionId+'",' +
                            '      "action_type": "INPERSONSIGN",' +
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+'",' +
                            '      "in_person_name": "'+inSignerName+'",' +
                            '      "in_person_email": "'+userEmail+'",' +
                             '  "signing_order": 1,' +
                            '      "fields": {' +
                            '        "image_fields": [' +
                                      getEshipImageFields(signActionId, documentId, 90, 690, 70, 30, pages) + 
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
            /*
                  String jsonPayload2 = '{' +
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
                            '            "x_coord": 405,' +
                            '            "y_coord": 690,' +
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
                            '      "recipient_email": "'+inSignerEmail+'",' +
                            '      "recipient_name": "'+username+'",' +
                            '      "in_person_name": "'+inSignerName+'",' +
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
                            '            "x_coord": 125,' +
                            '            "y_coord": 690,' + 
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
        */
           
        system.debug('request@@'+jsonPayload2);
        string urlEncodedBody3 = 'data=' + EncodingUtil.urlEncode(jsonPayload2, 'UTF-8');
        
         String jsonPayload3 =  '{' +
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
                                    getExhibishipImageFields(signActionId, documentId, 590, 500, 70, 30, pages) + 
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
                                     getExhibishipImageFields(signActionId, documentId, 130, 500, 70, 30, pages) +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
            system.debug('request@@'+jsonPayload2);
        string urlEncodedBody4 = 'data=' + EncodingUtil.urlEncode(jsonPayload3, 'UTF-8');
        
        String jsonPayload4 =  '{' +
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
                                    getNonACRExhibishipImageFields(signActionId, documentId, 590, 500, 70, 30, pages) + 
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
                                     getNonACRExhibishipImageFields(signActionId, documentId, 130, 500, 70, 30, pages) +
                            '        ]' +
                            '      }' +
                            '    }' +
                            '  ]' +
                            '}' +
                            '}';
        
            system.debug('request@@'+jsonPayload2);
        string urlEncodedBody5 = 'data=' + EncodingUtil.urlEncode(jsonPayload4, 'UTF-8');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        if(businessType == 'ACR' && BVCservice !='eSHIP' && BVCservice != 'ExhibiSHIP'){
              request.setBody(urlEncodedBody1);
        }else if(businessType == 'NON ACR' && BVCservice !='eSHIP' && BVCservice != 'ExhibiSHIP'){
            request.setBody(urlEncodedBody2);
        }else if(BVCservice =='eSHIP' && (businessType =='ACR' || businessType=='NON ACR')){
            request.setBody(urlEncodedBody3);
        }else if(BVCservice =='ExhibiSHIP' && businessType =='ACR'){
            request.setBody(urlEncodedBody4);
        }else if(BVCservice =='ExhibiSHIP' &&  businessType=='NON ACR'){
             request.setBody(urlEncodedBody5);
        }
      
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
                      intlg.BVCQuote__c = bv;
                      intlg.Status_Code__c =  String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c =  response.getBody();
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
        request.setTimeout(120000); 
        request.setHeader('Authorization', 'Zoho-oauthtoken ' + accessToken);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(urlEncodedBody);
         
        try{
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                System.debug('Response: ' + response.getBody());
                   
                 List<BVCQuote__c> qtList = [SELECT Id, Name,status__c, DocumentId__c, RequestId__c FROM BVCQuote__c where Id =:quoteID ];
                          
                        List<BVCQuote__c> updateQuoteList = new List<BVCQuote__c>();
                        
                        for(BVCQuote__c qt : qtList){   
                            qt.status__c = 'Contract Sent';
                          //  qt.Contract_Send_On__c = Date.today();
                            //qt.Expires_On__c =  Date.today().addDays(15); 
                            updateQuoteList.add(qt);
                        }
                              
                        update updateQuoteList;
                
            }else{
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response Body: ' + response.getBody());
                for(ID bv : quoteId){
                    integration_Log__c intlg = new integration_Log__c();
                      intlg.BVCQuote__c = bv;
                      intlg.Status_Code__c = String.valueOf(response.getStatusCode());
                      intlg.Response_JSON__c =  response.getBody();
                      intlg.ZohoAPIName__c = 'Send Document for signature API Error'; 
                        insert intlg;
                }
                
                
            }
            
        }catch(exception e){
            system.debug('Error:'+e.getMessage());
        }
        
    }
    
    public static String getACRImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
         
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
                    '"y_coord": '+520+',' +
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
                    '"y_coord": '+260+',' +
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
                    '"y_coord": '+400+',' +
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
                    '"y_coord": '+530+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i != 0 && i != 1 && i!= 2 && i != 3){
                    imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+y+',' +
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
     
    public static String getNonACRImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
         
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
                    '"y_coord": '+500+',' +
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
                    '"y_coord": '+260+',' +
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
                    '"y_coord": '+400+',' +
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
                    '"y_coord": '+520+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if( i != 0 && i != 3 && i != 2 && i != 1){
                    imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+y+',' +
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
    
    public static String getEshipImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
         
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
                    '"y_coord": '+650+',' +
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
                    '"y_coord": '+300+',' +
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
                    '"y_coord": '+780+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i != 2 && i !=0 && i !=1){
                     imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+y+',' +
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
    public static String getExhibishipImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
         
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
                    '"y_coord": '+520+',' +
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
                    '"y_coord": '+370+',' +
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
                    '"y_coord": '+450+',' +
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
                    '"y_coord": '+530+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if(i != 0 && i != 1 && i!= 2 && i != 3){
                    imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+y+',' +
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
    
    public static String getNonACRExhibishipImageFields(String actionId, String documentId, Integer x, Integer y, Integer width, Integer height, Integer totalPages){
        
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
                    '"y_coord": '+500+',' +
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
                    '"y_coord": '+370+',' +
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
                    '"y_coord": '+400+',' +
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
                    '"y_coord": '+520+',' +
                    '"abs_width": '+width+',' +
                    '"abs_height": '+height+',' +
                    '"page_no": '+i+',' +  // Adding for each page
                    '"is_resizable": true,' +
                    '"is_draggable": true,' +
                    '"description_tooltip": "Add your signature"' +
                    '}'
                );
                }
                if( i != 0 && i != 3 && i != 2 && i != 1){
                    imageFieldsList.add(
                    '{' +
                    '"field_name": "Signature",' +
                    '"field_label": "Signature",' +
                    '"field_type_name": "Signature",' +
                    '"document_id": "'+documentId+'",' +
                    '"action_id": "'+actionId+'",' +
                    '"is_mandatory": true,' +
                    '"x_coord": '+x+',' +
                    '"y_coord": '+y+',' +
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